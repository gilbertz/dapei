# -*- encoding : utf-8 -*-
class AddIndexToItem < ActiveRecord::Migration
  def change
    add_index :items, :title
    unless column_exists? :users, :comments_count
      add_column :users, :comments_count, :integer, :default=>0
    end
  end
end
