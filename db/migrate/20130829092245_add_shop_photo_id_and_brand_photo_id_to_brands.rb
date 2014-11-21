# -*- encoding : utf-8 -*-
class AddShopPhotoIdAndBrandPhotoIdToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :shop_photo_id, :integer

    add_column :brands, :brand_photo_id, :integer

  end
end
