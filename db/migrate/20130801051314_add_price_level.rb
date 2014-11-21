# -*- encoding : utf-8 -*-
class AddPriceLevel < ActiveRecord::Migration
  def change
    add_column :shops, :low_price, :integer
    add_column :shops, :high_price, :integer
    add_column :brands, :low_price, :integer
    add_column :brands, :high_price, :integer
  end

end
