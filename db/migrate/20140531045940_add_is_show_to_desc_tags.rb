# -*- encoding : utf-8 -*-
class AddIsShowToDescTags < ActiveRecord::Migration
  def change
    add_column :desc_tags, :is_show, :integer, :default => 1
  end
end
