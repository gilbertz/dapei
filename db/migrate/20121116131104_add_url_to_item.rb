# -*- encoding : utf-8 -*-
class AddUrlToItem < ActiveRecord::Migration
  def change
    add_column :items, :url, :string
    add_index  :items, :url
  end
end
