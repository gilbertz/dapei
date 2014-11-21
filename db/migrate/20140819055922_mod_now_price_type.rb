# -*- encoding : utf-8 -*-
class ModNowPriceType < ActiveRecord::Migration
  def change
    change_column :spiders, :now_price, :text
  end

end
