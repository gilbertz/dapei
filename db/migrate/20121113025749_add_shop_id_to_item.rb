# -*- encoding : utf-8 -*-
class AddShopIdToItem < ActiveRecord::Migration
  def change
    add_column :items, :shop_id, :integer
    add_index  :items, :shop_id
  end
end



