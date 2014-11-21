# -*- encoding : utf-8 -*-
class AddIndexToTables < ActiveRecord::Migration
  def change
    add_index :dapei_infos, :user_id
    add_index :dapei_infos, :category_id
    add_index :dapei_infos, :spec_uuid
    add_index :dapei_infos, :dapei_id

    add_index :dapei_item_infos, :dapei_info_id
    add_index :dapei_item_infos, :thing_id
    add_index :dapei_item_infos, :sjb_item_id
    add_index :dapei_item_infos, :sku_id
  end
end
