# -*- encoding : utf-8 -*-
class AddShopCountToBrand < ActiveRecord::Migration
  def change
    add_column :brands, :shops_count, :integer
  end
end
