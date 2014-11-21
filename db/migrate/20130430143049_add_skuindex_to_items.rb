# -*- encoding : utf-8 -*-
class AddSkuindexToItems < ActiveRecord::Migration
  def change
    add_index:items, [:shop_id, :sku_id]
  end
end
