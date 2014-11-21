# -*- encoding : utf-8 -*-
class AddNowPriceToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :now_price, :string
  end
end
