class AddColumnToTabelog < ActiveRecord::Migration
  def change
    add_column :tabelogs, :lunch_cost, :string
    add_column :tabelogs, :dinner_cost, :string
  end
end
