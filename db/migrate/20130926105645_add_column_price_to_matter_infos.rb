# -*- encoding : utf-8 -*-
class AddColumnPriceToMatterInfos < ActiveRecord::Migration
  def change
    add_column :matter_infos, :price, :string
  end
end
