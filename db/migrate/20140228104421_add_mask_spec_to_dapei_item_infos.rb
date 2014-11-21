# -*- encoding : utf-8 -*-
class AddMaskSpecToDapeiItemInfos < ActiveRecord::Migration
  def change
    add_column :dapei_item_infos, :mask_spec, :text

  end
end
