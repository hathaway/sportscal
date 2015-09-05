class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :home_team_id
    	t.integer :visitor_team_id
      t.datetime :start_time
      t.string :network
      t.string :yahoo_url

      t.integer :home_team_score, default: 0, null: false
      t.integer :visitor_team_score, default: 0, null: false
      t.string :current_status # 1st, 2nd, halftime, 3rd, 4th, final
      t.string :time_left

      t.timestamps null: false
    end

    add_index :games, :home_team_id
    add_index :games, :visitor_team_id
  end
end
