# -*- encoding : utf-8 -*-
class AddOriginPriceToItems < ActiveRecord::Migration
  def change
    add_column :items, :origin_price, :string

  end
end
