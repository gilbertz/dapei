# -*- encoding : utf-8 -*-
class AddSkusCountToBrands < ActiveRecord::Migration
  def change
    change_column :brands, :skus_count, :integer, :default => 0
  end
end
