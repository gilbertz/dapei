# -*- encoding : utf-8 -*-
class AddBuyUrlToItems < ActiveRecord::Migration
  def change
    add_column :items, :buy_url, :string

  end
end
