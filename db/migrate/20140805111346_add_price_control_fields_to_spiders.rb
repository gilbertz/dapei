# -*- encoding : utf-8 -*-
class AddPriceControlFieldsToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :max_shoes_price, :float
    add_column :spiders, :max_clothes_price, :float 
    add_column :spiders, :max_bags_price, :float
  end
end
