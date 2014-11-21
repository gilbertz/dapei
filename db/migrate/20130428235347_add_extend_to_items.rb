# -*- encoding : utf-8 -*-
class AddExtendToItems < ActiveRecord::Migration
  def change
    add_column :items, :brand_id, :integer

    add_column :items, :sku_id, :integer

    add_index :items, :brand_id
    
    add_index :items, :sku_id
  end
end
