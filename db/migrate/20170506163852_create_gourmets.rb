class CreateGourmets < ActiveRecord::Migration
  def change
    create_table :gourmets do |t|
      t.string :station_name
      t.string :genre
      t.integer :cost
      t.string :status
      t.timestamps null: false
    end
  end
end
