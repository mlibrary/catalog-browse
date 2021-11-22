require 'sinatra/base'

class CatalogBrowse < Sinatra::Base
  class BrowseCSS
    def initialize(app)
      @app = app
    end
    def call(env)
      @app.call(env.merge('PATH_INFO' => '/browse.css'))
    end
  end
end
