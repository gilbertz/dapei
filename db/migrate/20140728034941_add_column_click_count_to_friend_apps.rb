# -*- encoding : utf-8 -*-
class AddColumnClickCountToFriendApps < ActiveRecord::Migration
  def change
    add_column :friend_apps, :click_count, :integer, :default => 0
  end
end
