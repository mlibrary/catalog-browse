class SearchDropdown
  def initialize(type:,query:)
    @type = type
    @query = query
  end
  def url
    if @type == "browse_by_lc_callnumber"
      "/callnumber?query=#{browse_query}"
    else
      "https://search.lib.umich.edu/catalog?query=#{search_query}"
    end
    
  end
  
  def browse_by_type
    @type.split("_by_")[1]
  end

  def browse_query
    URI.encode_www_form_component(@query)
  end
  def search_query
    URI.encode_www_form_component("#{@type}:(#{@query})")
  end

end
