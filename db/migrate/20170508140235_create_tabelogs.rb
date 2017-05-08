class CreateTabelogs < ActiveRecord::Migration
  def change
    create_table :tabelogs do |t|
      t.integer :gourmet_id
      t.string :rst_name
      t.float  :hoshi
      t.string :url
      t.timestamps null: false
    end
  end
end
