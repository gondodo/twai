class AddColumnToTabelogs < ActiveRecord::Migration
  def change
    add_column :tabelogs, :img_url, :string
    add_column :tabelogs, :text, :string
  end
end
