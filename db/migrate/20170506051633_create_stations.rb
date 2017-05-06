class CreateStations < ActiveRecord::Migration
  def change
    create_table :stations do |t|
      t.integer :station_cd
      t.integer :station_g_cd
      t.string :station_name
      t.integer :line_cd
      t.integer :pref_cd
      t.string :post
      t.string :add
      t.float :lon
      t.float	:lat
      t.timestamps null: false
    end
  end
end
