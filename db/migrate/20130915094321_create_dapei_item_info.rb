# -*- encoding : utf-8 -*-
class CreateDapeiItemInfo < ActiveRecord::Migration
  def up
    create_table :dapei_item_infos do |t|
      t.integer :dapei_info_id
      t.float :x
      t.float :y
      t.float :w
      t.float :h
      t.integer :z
      t.string :item_type
      t.string :thing_id
      t.integer :sjb_item_id
      t.integer :sku_id
      t.timestamps
    end
  end

  def down
    drop_table :dapei_item_infos
  end
end
