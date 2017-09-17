class AddColumnToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :mode, :string
  end
end
