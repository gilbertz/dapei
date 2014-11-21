# -*- encoding : utf-8 -*-
class AddPostCountToUser < ActiveRecord::Migration
  def change
    add_column :users, :posts_count, :integer
  end
end
