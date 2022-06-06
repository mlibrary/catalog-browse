module CatalogSolrClient 
  class Configuration
    attr_accessor :solr_url, :core
    def initialize
      @solr_url = ""
      @core = "biblio"
    end
  end
end
