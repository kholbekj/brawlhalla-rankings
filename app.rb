require 'sinatra'
require 'memcachier'
require 'dalli'
require 'JSON'

set :cache, Dalli::Client.new

def teams
  @teams ||= settings.cache.fetch("teams")
  (@teams || []).to_json
end

get "/" do
  teams.length
end
