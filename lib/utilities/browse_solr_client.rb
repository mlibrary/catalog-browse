require "faraday"

class BrowseSolrClient
  def initialize(solr_url: S.solr_url, core: S.call_number_collection, match_field: "callnumber", q: "*:*")
    @conn = Faraday.new(
      url: solr_url
    ) do |f|
      f.request :json
      f.request :authorization, :basic, S.solr_user, S.solr_password if S.solrcloud_on?
      #  f.request :retry, {max: 1, retry_statuses: [500]}
      f.response :json
    end
    @path_prefix = "/solr/#{core}"
    @match_field = match_field
    @q = q
  end

  def browse_reference_on_top(reference_id:, rows: 20, field: "id")
    # square brackets includes reference in return
    range = "#{field}:[\"#{reference_id}\" TO *]"
    sort = "#{field} asc"
    browse(rows: rows, sort: sort, range: range)
  end

  def browse_reference_on_bottom(reference_id:, rows: 20, field: "id")
    # curly brackets exclues reference in return
    range = "#{field}:{* TO \"#{reference_id}\"}"
    sort = "#{field} desc"
    browse(rows: rows, sort: sort, range: range)
  end

  def browse(rows:, sort:, range:)
    query = {
      rows: rows,
      q: @q,
      fq: range,
      sort: sort
    }
    @conn.public_send(:get, "#{@path_prefix}/select", query)
  end

  def exact_matches(value:)
    query = {
      q: @q,
      fq: %(#{@match_field}:"#{value}"),
      sort: "id asc",
      rows: 5000
    }
    result = @conn.public_send(:get, "#{@path_prefix}/select", query)
    result.body["response"]["docs"]&.map { |x| x["id"] }
  rescue
    []
  end
end
