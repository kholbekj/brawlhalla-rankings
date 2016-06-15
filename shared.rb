require 'memcachier'
require 'dalli'

class Array
  # Slice array into num_groups equal groups, last group size of remainder.
  #
  # Example:
  # [a,b,c,d,e].in_groups(3)
  # => [[a,b],[c,d],[e]]
  #
  def in_groups(num_groups)
    return [] if num_groups == 0
    slice_size = (self.size/Float(num_groups)).ceil
    self.each_slice(slice_size).to_a
  end
end

# Stupid middle layer to deal with Heroku Memcachiers default limit per key
class Cache
  CHUCK_COUNT = 100 # Arbitrary number, 16 would be lowest for current amount.
  @cache_client = Dalli::Client.new

  # Split the array in smaller chunks and save them
  def self.store_teams(array)
    array.in_groups(100).each_with_index do |chunk, index|
      @cache_client.set("teams-#{index}", chunk)
    end
  end

  # Fetch and concatenate sharded object
  def self.get_teams
    (0..99).flat_map do |index|
      @cache_client.get("teams-#{index}")
    end
  end
end
