# -*- encoding : utf-8 -*-
class AddCommentCountToCommentable < ActiveRecord::Migration
  def change
    add_column :items, :comments_count, :integer
    add_column :posts, :comments_count, :integer
    add_column :items, :likes_count, :integer
    add_column :posts, :likes_count, :integer
  end
end
