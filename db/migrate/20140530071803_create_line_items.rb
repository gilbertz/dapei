# -*- encoding : utf-8 -*-
class CreateLineItems < ActiveRecord::Migration
  def up
    create_table :line_items do |t|
      t.integer :sku_id
      t.string :name
      t.integer :cart_id
      t.integer :order_id
      t.integer :quantity
      t.integer :state, :default => 0
      t.timestamps
    end

    add_index :line_items, :cart_id
    add_index :line_items, :order_id

  end

  def down
    drop_table :line_items
  end
end
