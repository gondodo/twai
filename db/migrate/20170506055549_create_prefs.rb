class CreatePrefs < ActiveRecord::Migration
  def change
    create_table :prefs do |t|
      t.integer :pref_cd
      t.string :pref_name
      t.timestamps null: false
    end
  end
end
