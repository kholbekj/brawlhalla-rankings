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

get "/" do
  JSON.generate({ team_count: teams.length})
end

get "/search/:query" do
  query = params[:query]
  if query =~ /\d+?-\d+?/
    low, high = query.split('-').map(&:to_i)
    JSON.generate(search(low, high))
  elsif query.to_i.to_s == query
    elo = query.to_i
    JSON.generate(search(elo))
  else
    name = query
    JSON.generate(search(name))
  end
end
