# -*- encoding : utf-8 -*-
class CreateTemplateItems < ActiveRecord::Migration
  def up
    create_table :template_items do |t|
      #搭配模板的id
      t.integer :dapei_template_id

      #是否是需要用户搭配item  1 0
      t.integer :template_item_type
      t.string :visibility
      t.string :a
      t.string :masking_policy
      t.integer :thing_id
      t.string :oa
      t.string :state
      t.string :y
      t.string :url
      t.integer :old_thing_id
      t.string :sale_price
      t.string :imgurl
      t.string :title
      t.string :price

      #dapei-template-item-type：image-or-ph-or-colorblock-or-text
      t.string :item_type
      t.string :visible_ratio
      t.integer :z
      t.integer :ow
      t.string :w
      t.integer :brand_id
      t.string :x
      t.string :brand
      t.integer :opacity
      t.string :currency
      t.string :host_type
      t.integer :category_id
      t.integer :instock
      t.string :h
      t.string :oh
      t.string :displayurl
      t.string :createdby
      t.string :transform
      t.integer :feed
      t.integer :bkgd
      t.string :host
      t.integer :paid
      t.string :dropHint
      t.timestamps
    end
  end

  def down
    drop_table :template_items
  end
end
