class CreateBirds < ActiveRecord::Migration
  def change
    create_table :birds do |t|
      t.string :account
      t.string :tweet
      t.string :post
      t.timestamps null: false
    end
  end
end
