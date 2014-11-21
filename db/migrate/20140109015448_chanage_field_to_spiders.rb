# -*- encoding : utf-8 -*-
class ChanageFieldToSpiders < ActiveRecord::Migration
  def up
    change_column :spiders, :start_page_4, :text
    change_column :spiders, :start_page_5, :text
    change_column :spiders, :start_page_6, :text
    change_column :spiders, :start_page_7, :text
    change_column :spiders, :start_page_8, :text
    change_column :spiders, :start_page_9, :text
    change_column :spiders, :start_page_11, :text
    change_column :spiders, :start_page_12, :text
    change_column :spiders, :start_page_13, :text
    change_column :spiders, :start_page_14, :text
  end

  def down
  end
end
