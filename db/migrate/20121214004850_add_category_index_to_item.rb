# -*- encoding : utf-8 -*-
class AddCategoryIndexToItem < ActiveRecord::Migration
  def change
    add_index :items, :category_id
  end
end
