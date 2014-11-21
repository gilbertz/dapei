# -*- encoding : utf-8 -*-
class UpdateColumnToSpiders < ActiveRecord::Migration
  def up
    change_column :spiders, :start_page, :text
    change_column :spiders, :product_page, :text
    change_column :spiders, :next_page, :text
    change_column :spiders, :ptitle, :text
    change_column :spiders, :pprice, :text
    change_column :spiders, :pdesc, :text
    change_column :spiders, :pimgs, :text
    change_column :spiders, :others, :text
  end

  def down
  end
end
