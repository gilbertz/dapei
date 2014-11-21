# -*- encoding : utf-8 -*-
class AddColumnColorImageUrl < ActiveRecord::Migration
  def up
    add_column :sku_properties, :color_image_url, :string
  end

  def down
    remove_column :sku_properties, :color_image_url
  end
end
