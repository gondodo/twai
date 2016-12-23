class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :mid
      t.string :display_name
      t.integer :status

      t.timestamps null: false
    end
  end
end
