# -*- encoding : utf-8 -*-
class AddPriceRangeToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :min_price, :float
    add_column :categories, :max_price, :float
  end
end
