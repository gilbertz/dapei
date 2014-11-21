# -*- encoding : utf-8 -*-
class AddStartpage10ToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :start_page_10, :text
  end
end
