# -*- encoding : utf-8 -*-
class AddCategoryIdToItem < ActiveRecord::Migration
  def change
    add_column :items, :category_id, :integer
  end
end
