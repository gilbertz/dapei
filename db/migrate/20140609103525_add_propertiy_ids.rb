# -*- encoding : utf-8 -*-
class AddPropertiyIds < ActiveRecord::Migration
  def up
    create_table :property_property_values do |t|
      t.integer :line_item_id
      t.integer :property_id
      t.integer :property_value_id
    end

    add_index :property_property_values, :property_id
    add_index :property_property_values, :line_item_id
    add_index :property_property_values, [:line_item_id, :property_id, :property_value_id], :unique => true, :name => "property_lpp"
  end

  def down
    drop_table :property_property_values
  end
end
