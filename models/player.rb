class Player < ActiveRecord::Base
  has_and_belongs_to_many :teams

  def to_hash
    { name: name, elo: elo, tier: tier, region: region }
  end
end
