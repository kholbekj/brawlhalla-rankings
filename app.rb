require 'json'
require 'sinatra'
require_relative 'shared'

def teams
  @teams ||= Cache.get_teams
  @teams || []
end

def search(first, second=first)
  if first.is_a? Fixnum
    teams.select {|t| (first..second).include? t['elo'] }
  else
    teams.select {|t| t['player_1'].downcase.include?(first.downcase) || t['player_2'].downcase.include?(first.downcase) }
  end
end

# Just a status indicator, show number of cached teams
get "/" do
  JSON.generate({ team_count: teams.length})
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
