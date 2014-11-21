# -*- encoding : utf-8 -*-
class CreatePropertiesValues < ActiveRecord::Migration
  def up
    create_table :properties_values do |t|
      t.integer :sku_id
      t.integer :property_id
      t.string :value
    end
  end

  def down
    drop_table :properties_values
  end
end
