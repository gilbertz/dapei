# -*- encoding : utf-8 -*-
class AddMissingIndexes < ActiveRecord::Migration
  def change
    add_index :posts, :user_id
    add_index :posts, :category_id
    add_index :taggings, [:tagger_id, :tagger_type]
    add_index :authentications, :user_id
    add_index :game_materials, :category_id
    add_index :sku_promotions, :sku_id
    add_index :brands, :category_id
    add_index :spiders, :brand_id
    add_index :crawler_templates, :brand_id
    add_index :crawler_templates, :mall_id
    add_index :template_items, :dapei_template_id
    add_index :categories, :parent_id
    add_index :line_items, :sku_id
    add_index :shops, :mall_id
    add_index :shops, :category_id
    add_index :messages, :accept_id            
    add_index :messages, :sender_id
    add_index :orders, :user_id
    add_index :orders, :ship_address_id              
    add_index :photos, :author_id      
  end
end
