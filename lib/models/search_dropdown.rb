class SearchDropdown
  def self.for(type:, query:)
    if type.start_with?("browse_by")
      SearchDropdown::Browse.new(type, query)
    else
      SearchDropdown::Search.new(type,query)
    end
  end
  def initialize(type,query)
    @type = type
    @query = query
  end
  
end
class SearchDropdown::Browse < SearchDropdown
  def url
    case @type
    when "browse_by_lc_callnumber"
      "/callnumber?query=#{encoded_query}"
    else
      #Users shouldn't be able to do this; 
      #Send them back to search without their query if it happens.
      "https://search.lib.umich.edu"
    end
  end
  private
  def encoded_query
    URI.encode_www_form_component(@query)
  end

end
class SearchDropdown::Search < SearchDropdown
  def url
    "https://search.lib.umich.edu/catalog?query=#{encoded_query}"
  end

  private
  def encoded_query
    URI.encode_www_form_component("#{@type}:(#{@query})")
  end
end
