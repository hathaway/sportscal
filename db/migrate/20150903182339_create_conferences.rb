class CreateConferences < ActiveRecord::Migration
  def change
    create_table :conferences do |t|
      t.string :name
      t.string :abbreviation

      t.integer :teams_count, default: 0, null: false

      t.timestamps null: false
    end
  end
end
