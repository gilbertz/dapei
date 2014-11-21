# -*- encoding : utf-8 -*-
class AddDetailToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :properties, :string

    add_column :brands, :property_keys, :string

    add_column :brands, :likes_count, :integer

    add_column :brands, :comments_count, :integer

    add_column :brands, :dispose_count, :integer

    add_column :brands, :url, :string

    add_column :brands, :type, :integer

    add_column :brands, :level, :integer

    add_column :brands, :rating, :integer

    add_column :brands, :address, :string

    add_column :brands, :products, :string

    add_column :brands, :tags, :string

    add_column :brands, :phone_number, :string

    add_column :brands, :avatar_id, :integer


    add_column :brands, :homepage, :string

    add_column :brands, :weibo, :string

    add_column :brands, :tmall, :string

    add_column :brands, :weixin, :string

    add_column :brands, :crawled_source, :string

    add_index :brands, :url
   
    add_index :brands, :type
  
    add_index :brands, :level

    add_index :brands, :rating

  end
end
