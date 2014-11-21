# -*- encoding : utf-8 -*-
class AddOrigPriceToMatterInfos < ActiveRecord::Migration
  def change
    add_column :matter_infos, :orig_price, :string
  end
end
