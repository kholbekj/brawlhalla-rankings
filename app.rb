require 'json'
require 'sinatra'
require "sinatra/activerecord"
require 'pg'
require_relative 'models/team'
require_relative 'models/player'
require 'pry'

def search(first, second=first)
  if first.is_a? Fixnum
    Team.where(elo: (first..second)).to_a.map(&:to_hash)
  else
    Player.where("name ILIKE ?", "%#{first}%").flat_map(&:teams).map(&:to_hash)
  end
end

options "*" do
  response.headers["Allow"] = "HEAD,GET,PUT,DELETE,OPTIONS"

  # Needed for AngularJS
  response.headers["Access-Control-Allow-Headers"] = "X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept"
  response.headers["Access-Control-Allow-Origin"] = "*"

  halt 200
end

# Just a status indicator, show number of cached teams
get "/" do
  JSON.generate({ team_count: Team.count })
end

# Search endpoint. Can either find by partial name match, elo, or elo-range.
# Case-insensitive.
#
# Examples:
#
# /search/dobrein
# /search/1337
# /search/2000-2050
#
get "/search/:query" do
  response.headers["Access-Control-Allow-Origin"] = "*"
  query = params[:query]
  if query =~ /\d+?-\d+?/ # Match format number, dash, number
    low, high = query.split('-').map(&:to_i)
    JSON.generate(search(low, high))
  elsif query.to_i.to_s == query # Matches a number
    elo = query.to_i
    JSON.generate(search(elo))
  else # There's something else, we assume it's a name
    name = query
    JSON.generate(search(name))
  end
end
