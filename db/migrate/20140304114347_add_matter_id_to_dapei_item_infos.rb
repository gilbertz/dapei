# -*- encoding : utf-8 -*-
class AddMatterIdToDapeiItemInfos < ActiveRecord::Migration
  def change
    add_column :dapei_item_infos, :matter_id, :integer

  end
end
