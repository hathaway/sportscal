class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.string :division

      t.integer :ap_rank
      t.integer :coaches_rank

      t.string :yahoo_url
      t.string :yahoo_slug

      t.belongs_to :conference, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
