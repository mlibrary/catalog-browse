class SearchDropdown
  def initialize(type:,query:)
    @type = type
    @query = query
  end
  def url
    if type.start_with?('browse_by')
      "/#{@type}?query=#{browse_query}"
    elsif
      "https://search.lib.umich.edu/catalog?query=#{search_query}"
    end
    
  end

  def browse_query
    URI.encode_www_form_component(query)
  end
  def search_query
    URI.encode_www_form_component("#{@type}:(#{@query})")
  end

end
