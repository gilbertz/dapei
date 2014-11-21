# -*- encoding : utf-8 -*-
class AddIndexToItems < ActiveRecord::Migration
  def change
    add_index:items, [:brand_id, :sku_id]
  end
end
