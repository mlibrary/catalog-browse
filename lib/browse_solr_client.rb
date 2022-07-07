require "faraday"
require_relative "./catalog_solr_client/configuration"
require_relative "./catalog_solr_client/client"

module BrowseSolrClient
  class << self
    def client(solr_url: nil, core: nil)
      Client.new
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
