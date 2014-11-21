# -*- encoding : utf-8 -*-
class AddDapeisCountToUsers < ActiveRecord::Migration
  def change
    add_column :users, :dapeis_count, :integer, :default => 0
    add_index :users, :dapeis_count
  end
end
