require 'httparty'

class SolrClient
  include HTTParty
  base_uri "#{ENV.fetch('CATALOG_SOLR')}"

  def browse_reference_on_top(reference_id:, rows: 5, core: "callnumbers")
    range = "id:[\"#{reference_id}\" TO *]"
    sort = "id asc"
    browse(core: core, rows: rows, sort: sort, range: range)
  end

  def browse_reference_on_bottom(reference_id:, rows: 5, core: "callnumbers")
    range = "id:[* TO \"#{reference_id}\"]"
    sort = "id desc"
    browse(core: core, rows: rows, sort: sort, range: range)
  end


  def browse(core: "callnumbers",rows: 5,sort: "id asc",range:'id:{"Z 253 .U6 1963" TO *}')
    query = {
      rows: rows,
      q: '*:*',
      fq: [range],
      sort: sort,
    }
    self.class.get("/#{core}/select", query: query)
  end

  def get_bibs(bib_ids:, core: "biblio")
    query = {
      q: "id:(#{bib_ids.join(" OR ")})",
      rows: bib_ids.size
    }
    self.class.get("/#{core}/select", query: query)
  end
end

