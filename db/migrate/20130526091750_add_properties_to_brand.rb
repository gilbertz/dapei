# -*- encoding : utf-8 -*-
class AddPropertiesToBrand < ActiveRecord::Migration
  def change
    add_column :brands, :price_level, :string
    add_column :brands, :brand_intro, :string
  end
end
