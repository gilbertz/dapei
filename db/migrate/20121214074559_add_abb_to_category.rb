# -*- encoding : utf-8 -*-
class AddAbbToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :items_count, :integer
    add_column :categories, :abb, :string
    add_index :categories, :abb 
  end
end
