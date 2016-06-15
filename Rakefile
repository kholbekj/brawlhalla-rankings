require 'httparty'
require 'nokogiri'
require 'pry'
require 'ruby-progressbar'
require 'json'
require 'memcachier'
require 'dalli'

task :scrape do
  # Base url to scrape
  base_page = 'http://www.brawlhalla.com/rankings/2v2/'
  # Found with a binary search, should be dynamic instead.
  PAGE_COUNT = 6424
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

      # Find their ELO
      elo = row.children.last.children.text.to_i

      # Add the data to memory
      @teams.push({ 'player_1' => player_1, 'player_2' => player_2, 'elo' => elo })
    end

    # Make progressbar move 1 page
    progressbar.increment
  end

  c = Dalli::Client.new
  c.set('teams', @teams)
  puts "Done!"
end
