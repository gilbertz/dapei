# -*- encoding : utf-8 -*-
class AddIndexToFollow < ActiveRecord::Migration
  def change
    add_index "follows", ["followable_id", "followable_type", "follower_type", "blocked"], :name => 'following_index'
  end
end
