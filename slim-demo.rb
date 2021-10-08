require "sinatra"
require "slim"

get "/" do
  slim :browse
end
