require 'sinatra'
require 'memcachier'
require 'dalli'
require 'json'

set :cache, Dalli::Client.new

def teams
  @teams ||= settings.cache.fetch("teams")
  (@teams || []).to_json
end

get "/" do
  teams.length
end
