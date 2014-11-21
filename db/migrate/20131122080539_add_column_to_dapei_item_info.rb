# -*- encoding : utf-8 -*-
class AddColumnToDapeiItemInfo < ActiveRecord::Migration
  def change
    add_column :dapei_item_infos, :transform, :string
  end
end
