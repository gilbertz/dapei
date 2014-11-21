# -*- encoding : utf-8 -*-
class AddStartPage9ToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :start_page_9, :string

  end
end
