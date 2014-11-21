# -*- encoding : utf-8 -*-
class AddColumnDisplayPriceToMatterInfos < ActiveRecord::Migration
  def change
    add_column :matter_infos, :display_price, :string
  end
end
