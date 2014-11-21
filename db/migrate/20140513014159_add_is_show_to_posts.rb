# -*- encoding : utf-8 -*-
class AddIsShowToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :is_show, :integer, :default => 0, :null => false
  end
end
