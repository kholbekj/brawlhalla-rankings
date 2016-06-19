class Team < ActiveRecord::Base
  has_and_belongs_to_many :players

  def to_hash
    { players: [players.map(&:to_hash)], elo: elo, tier: tier }  
  end
end
