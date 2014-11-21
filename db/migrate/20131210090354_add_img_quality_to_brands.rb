# -*- encoding : utf-8 -*-
class AddImgQualityToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :img_quality, :integer

  end
end
