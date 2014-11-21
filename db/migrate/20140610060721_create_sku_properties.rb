# -*- encoding : utf-8 -*-
class CreateSkuProperties < ActiveRecord::Migration
  def up
    create_table :sku_properties do |t|
      t.integer :sku_id
      t.integer :property_id
      t.string :value
      t.integer :count, :default => 0
      t.timestamps
    end

    add_index :sku_properties, :sku_id
    add_index :sku_properties, :property_id

  end

  def down
    drop_table :sku_properties
  end
end
