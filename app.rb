require 'sinatra'
require 'memcachier'
require 'dalli'

set :cache, Dalli::Client.new

def teams
  @teams ||= settings.cache.fetch("teams")
  @teams || []
end

def search(first, second=first)
  if first.is_a? Fixnum
    teams.select {|t| (first..second).include? t['elo'] }
  else
    teams.select {|t| t['player_1'].include?(first) || t['player_2'].include?(first) }
  end
end

get "/" do
  teams.length.to_s
end

get "/search/:query" do
  if params[:query] =~ /\d+?-\d+?/
    low, high = query.split('-').map(&:to_i)
    JSON.generate(search(low, high))
  elsif params[:query].to_i.to_s == params[:query]
    elo = params[:query].to_i
    JSON.generate(search(elo))
  else
    name = params[:query]
    JSON.generate(search(name))
  end
end
