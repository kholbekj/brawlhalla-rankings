require 'sinatra'
require 'memcachier'
require 'dalli'

set :cache, Dalli::Client.new

def teams
  @teams ||= settings.cache.fetch("teams")
  @teams || []
end

get "/" do
  teams.length
end
