class AddColumnCoinToUsers < ActiveRecord::Migration
  def change
    add_column :users, :coin, :integer, default: 0
  end
end
