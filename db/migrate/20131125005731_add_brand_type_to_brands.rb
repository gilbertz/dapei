# -*- encoding : utf-8 -*-
class AddBrandTypeToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :brand_type, :integer

    add_column :brands, :brand_type_1, :integer

    add_column :brands, :brand_type_2, :integer

  end
end
