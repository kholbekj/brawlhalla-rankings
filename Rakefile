require 'httparty'
require 'nokogiri'
require 'pry'
require 'ruby-progressbar'
require 'json'
require 'sinatra/activerecord'
require_relative 'models/team'
require_relative 'models/player'


require "sinatra/activerecord/rake"

namespace :db do
  task :load_config do
    require "./app"
  end
end

task :scrape do
  # Base url to scrape
  base_page = 'http://www.brawlhalla.com/rankings/2v2/'
  # Found with a binary search, should be dynamic instead. Kept for now for progressbar.
  PAGE_COUNT = 20
  @teams = []

  # Some feedback is nice when processing 6k pages
  progressbar = ProgressBar.create(title: 'Pages processed', total: PAGE_COUNT, format: "%a %e %P% Processed: %c of %C")

  # For every single page
  (1..PAGE_COUNT).each do |p|

    # Make the full url of the page
    url = base_page + p.to_s

    page = HTTParty.get(url)
    # Parse the page to make i easier to work with
    parsed_page = Nokogiri::HTML(page)

    # For every row in the rankings table, except the ones with different information
    parsed_page.css('tbody').children[5..-2].map do |row|
      # Ensure row is ok
      next if row.children[2].children.first.nil? || row.children[3].children.first.nil?
      # Find the two player names
      player_1 = row.children[2].children.first.text
      player_2 = row.children[3].children.first.text

      p1 = Player.find_or_create_by(name: player_1)
      p2 = Player.find_or_create_by(name: player_2)

      # Find their ELO
      elo = row.children.last.children.text.to_i

      # find common team
      team = (p1.teams & p2.teams).first

      # If there is a common team already
      if team

        # If the elo has changed
        unless team.elo == elo

          # Update elo
          team.update_attribute(:elo, elo)
        end
      else

        # Create the team
        Team.create(players:[p1, p2], elo: elo)
      end
    end

    # Make progressbar move 1 page
    progressbar.increment
  end

  puts "Done!"
end
