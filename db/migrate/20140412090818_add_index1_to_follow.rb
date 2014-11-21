# -*- encoding : utf-8 -*-
class AddIndex1ToFollow < ActiveRecord::Migration
  def change
    add_index "follows", "follower_id"
    add_index "follows", "followable_id"
    add_index "follows", "followable_type"
    add_index "follows", "follower_type"
    add_index "follows", "blocked"
  end
end
