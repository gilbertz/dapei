# -*- encoding : utf-8 -*-
class CreateRelItems < ActiveRecord::Migration
  def self.up
    create_table :rel_items do |t|
      t.integer "dapei_id" 
      t.integer "item_id"
      t.timestamps
    end

    add_index :rel_items, :dapei_id
    add_index :rel_items, :item_id
    add_index :rel_items, [:dapei_id, :item_id]
    add_index :rel_items, [:item_id, :dapei_id]
  end

  def self.down
    drop_table :rel_items
  end
end
