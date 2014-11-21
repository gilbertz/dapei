# -*- encoding : utf-8 -*-
class AddUsersFollowingCount < ActiveRecord::Migration
  def up
    #add_column :users, :following_count, :integer, :default => 0
    #add_column :users, :follower_count, :integer, :default => 0
  end

  def down
    #remove_column :users, :following_count
    #remove_column :users, :follower_count
  end
end
