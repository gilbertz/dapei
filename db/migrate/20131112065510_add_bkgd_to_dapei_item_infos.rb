# -*- encoding : utf-8 -*-
class AddBkgdToDapeiItemInfos < ActiveRecord::Migration
  def change
    add_column :dapei_item_infos, :bkgd, :integer, :default => 0
  end
end
