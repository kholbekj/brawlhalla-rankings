require 'HTTParty'
require 'Nokogiri'
require 'Pry'
require 'ruby-progressbar'
require 'JSON'

# Base url to scrape
base_page = 'http://www.brawlhalla.com/rankings/2v2/'
if ARGV[0] == 'scrape' # To make sure we really wanna re-scrape the site

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

  # Save the result to file, so we can opt to not scrape every time we run
  File.write('team_data.json', @teams.to_json)
else # We just read in data from previous scrape.
  begin
    data = File.read('team_data.json')
  rescue Errno::ENOENT
    puts 'No save file found. Run with scrape option to fetch data from website.'
    exit
  end
  @teams = JSON.load(data)
end

def search(first, second=first)
  if first.is_a? Fixnum
    @teams.select {|t| (first..second).include? t['elo'] }
  else
    @teams.select {|t| t['player_1'].include?(first) || t['player_2'].include?(first) }
  end
end

Pry.start(binding)
