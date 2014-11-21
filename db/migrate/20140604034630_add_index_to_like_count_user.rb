# -*- encoding : utf-8 -*-
class AddIndexToLikeCountUser < ActiveRecord::Migration
  def change
    add_index :like_count_users, :user_id
    add_index :like_count_users, :created_at
  end
end
