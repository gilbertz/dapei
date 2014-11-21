# -*- encoding : utf-8 -*-
class AddIndexToDapeiItemInfos < ActiveRecord::Migration
  def change
    add_index "dapei_item_infos", "matter_id"
  end
end
