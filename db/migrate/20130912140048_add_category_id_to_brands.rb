# -*- encoding : utf-8 -*-
class AddCategoryIdToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :category_id, :integer

  end
end
