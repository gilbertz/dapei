# -*- encoding : utf-8 -*-
class AddBrandType3ToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :brand_type_3, :integer

  end
end
