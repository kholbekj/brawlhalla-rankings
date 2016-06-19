class CreatePlayersAndTeams < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.string :name, null: false
      t.integer :elo
      t.integer :tier
      t.integer :region
      t.timestamps null: false
    end

    create_table :teams do |t|
      t.integer :elo, null: false
      t.integer :tier
      t.timestamps null: false
    end

    create_table :players_teams, id: false do |t|
      t.belongs_to :player, index: true
      t.belongs_to :team, index: true
    end
  end
end
