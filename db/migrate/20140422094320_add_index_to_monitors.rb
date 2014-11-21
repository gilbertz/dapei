# -*- encoding : utf-8 -*-
class AddIndexToMonitors < ActiveRecord::Migration
  def change

    add_index :users, :created_at
    add_index :users, :current_sign_in_at
    add_index :items, :created_at
    add_index :skus, :created_at
    add_index :shops, :created_at
    add_index :discounts, :created_at

  end
end
