require 'memcachier'
require 'dalli'

class Array
  # Slice array into n equal groups
  def in_groups(num_groups)
    return [] if num_groups == 0
    slice_size = (self.size/Float(num_groups)).ceil
    self.each_slice(slice_size).to_a
  end
end

class Cache
  CHUCK_COUNT = 100
  @cache_client = Dalli::Client.new

  def self.store_teams(array)
    array.in_groups(100).each_with_index do |chunk, index|
      @cache_client.set("teams-#{index}", chunk)
    end
  end

  def self.get_teams
    (0..99).flat_map do |index|
      @cache_client.get("teams-#{index}")
    end
  end
end
