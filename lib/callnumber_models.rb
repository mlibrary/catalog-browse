## frozen_string_literal: true

require 'simple_solr_client'
require 'byebug'

require 'delegate'

class SolrDocWrapper < SimpleDelegator

  attr_accessor :exact_match, :this_callnumber, :cn_key

  def initialize(solrdoc, exact_match: false)
    @solrdoc = solrdoc
    __setobj__ @solrdoc
    @exact_match = exact_match
  end

  def id
    @solrdoc['id']
  end

end

class SolrClientWrapper
  SSC          = SimpleSolrClient::Client.new ENV.fetch('CATALOG_SOLR')
  CN_CORE      = SSC.core('callnumbers')
  CATALOG_CORE = SSC.core('biblio')

  def self.cn_core
    CN_CORE
  end
  def self.catalog_core
    CATALOG_CORE
  end
end

class CallnumberRangeQuery

  attr_reader :callnumber, :cn_core, :catalog_core, :rows
  attr_accessor :query, :filters, :results, :key, :page

  attr_accessor :first_page, :last_page

  def initialize(callnumber:,
                 key: nil,
                 page: 0,
                 cn_core: SolrClientWrapper.cn_core,
                 catalog_core: SolrClientWrapper.catalog_core,
                 query: '*:*',
                 filters: [],
                 rows: 30
   )
    @callnumber   = callnumber
    @page         = page
    @cn_core      = cn_core
    @catalog_core = catalog_core
    @query        = query
    @filters      = filters
    @rows         = rows
    @results      = nil
    @key          = key
  end

  def clone_to(klass, **kwargs)
    args = {
      callnumber:   self.callnumber,
      key:          self.key,
      page:         self.page,
      cn_core:      self.cn_core,
      catalog_core: self.catalog_core,
      query:        self.query,
      filters:      self.filters,
      rows:         self.rows
    }.merge(kwargs)

    klass.new(**args)
  end

  def base_query_args
    args = {
      rows: rows,
      q:    query,
      fq:   filters
    }
    args
  end

  def sort
    'id asc'
  end

  def range
    raise "Must implement 'range' in subclass"
  end

  def query_args
    args        = base_query_args.dup
    args[:fq]   = filters + [range]
    args[:sort] = sort
    args
  end

  def bib_ids
    cn_key_query.docs.map { |h| h['bib_id'] }
  end

  def cn_key_query
    @cn_key_query ||= CNKeyQuery.new(cn_core, query_args)
  end

  def cn_by_bib_id
    @bib_id_map = cn_key_query.docs.each_with_object(Hash.new) do |cnd, h|
      h[cnd['bib_id']] = cnd
    end
  end

  def next_page_key
    docs.last.cn_key
  end

  def previous_page_key
    docs.first.cn_key
  end

  # placeholders

  def has_next_page?
    true
  end

  def has_previous_page?
    true
  end

  def decorate_catalog_docs(docs)
    swdocs = docs.map { |d| SolrDocWrapper.new(d) }
    swdocs.each do |sw|
      bib_id             = sw.id
      sw.this_callnumber = cn_by_bib_id[bib_id]['callnumber']
      sw.cn_key          = cn_by_bib_id[bib_id]['id']
    end
  end

  def catalog_docs_from_ids
    return [] if bib_ids.empty?
    @catalog_docs_by_ids ||= begin
                               q = 'id:(' + bib_ids.join(" OR ") + ')'
                               decorate_catalog_docs(catalog_core.get('select', q: q, rows: bib_ids.size)['response']['docs'])
                             end
  end

  def reorder_docs(documents)
    documents
  end

  def docs
    @results ||= begin
                   cdocs = catalog_docs_from_ids
                   bib_ids.map do |bib_id|
                     d = cdocs.find { |x| x['id'] == bib_id }
                     puts "Can't find doc for #{bib_id}" unless d
                     d
                   end
                 end
    reorder_docs(@results).take(rows)
  end
end

class NextPage < CallnumberRangeQuery

  def next_page
    self.clone_to(NextPage, key: next_page_key, page: page + 1)
  end

  def previous_page
    self.clone_to(NextPage, key: previous_page_key, page: page - 1)
  end

  def url_args
    {
      page:       page,
      callnumber: callnumber,
      key:        key
    }
  end

  def has_next_page?
    !cn_key_query.hit_an_edge?
  end

  def has_previous_page?
    true
  end

  def sort
    "id asc"
  end

  def range
    %Q(id:{"#{key}" TO *])
  end

end

class FirstPage < NextPage

  def leading_results
    @ppc ||= clone_to(PreviousPage, key: callnumber, rows: 2)
  end

  def exact_matches
    @epc ||= clone_to(ExactPage, key: callnumber)
  end

  def next_results
    puts "Starting with #{rows} rows"
    rows_needed = rows - exact_matches.docs.size - 2
    puts "Rows needed: #{rows_needed}"
    if exact_matches.docs.empty?
      newkey = callnumber
    else
      newkey = exact_matches.next_page_key
    end
    puts "Using #{newkey} as new key"
    @npc ||= clone_to(NextPage, key: newkey, rows: rows_needed)
  end

  def has_next_page?
    !next_results.cn_key_query.hit_an_edge?
  end

  def has_previous_page?
    !leading_results.cn_key_query.hit_an_edge?
  end

  def docs
    d = leading_results.docs
    e = exact_matches.docs
    if e.empty?
      e = [:placeholder]
    end
    n = next_results.docs
    d + e + n
  end

end

class PreviousPage < NextPage
  def sort
    "id desc"
  end

  def has_next_page?
    true
  end

  def has_previous_page?
    !cn_key_query.hit_an_edge?
  end

  def range
    %Q(id:[* TO "#{key}"})
  end

  def reorder_docs(documents)
    documents.reverse
  end

end

class ExactPage < NextPage

  # Not really a range in this case...
  def range
    r = %Q(callnumber:"#{callnumber}")
    puts r
    r
  end

  def docs
    d = super
    d.each { |sd| sd.exact_match = true }
  end
end

class CNKeyQuery

  attr_reader :cn_core, :resp, :query_args, :hit_an_edge

  def initialize(cn_core, query_args)
    @cn_core       = cn_core
    @query_args    = query_args
    @no_more_pages = false
  end

  def docs
    @docs ||= get_docs.take(rows)
  end

  def rows
    query_args[:rows]
  end

  def rows_plus_one_to_check_for_edge
    query_args[:rows] + 1
  end

  def hit_an_edge?
    get_docs
    @hit_an_edge
  end

  def query_args_with_one_more_row
    query_args.merge({ rows: rows_plus_one_to_check_for_edge })
  end

  def get_docs
    puts "CNKeyQuery args are " + query_args.to_s
    @resp        ||= cn_core.get('select', query_args_with_one_more_row)
    d            = @resp['response']['docs']
    @hit_an_edge = (d.size <= rows)
    d
  end

  def first_key
    docs.first['id']
  end

  def last_key
    docs.last['id']
  end

end
