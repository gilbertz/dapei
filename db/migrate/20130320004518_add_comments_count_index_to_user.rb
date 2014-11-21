# -*- encoding : utf-8 -*-
class AddCommentsCountIndexToUser < ActiveRecord::Migration
  def change
    add_index :users, :comments_count
  end
end
