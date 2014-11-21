# -*- encoding : utf-8 -*-
class AddSoldOutToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :sold_out, :text 
  end
end
