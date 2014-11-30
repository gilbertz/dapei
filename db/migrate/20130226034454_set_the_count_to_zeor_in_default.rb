# -*- encoding : utf-8 -*-
class SetTheCountToZeorInDefault < ActiveRecord::Migration
  def change
    change_column :items, :likes_count, :integer, :default=>0
    change_column :items, :comments_count, :integer, :default=>0
    change_column :posts, :comments_count, :integer, :default=>0
    change_column :posts, :likes_count, :integer, :default=>0
  end
end
