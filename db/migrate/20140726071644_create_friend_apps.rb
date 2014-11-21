# -*- encoding : utf-8 -*-
class CreateFriendApps < ActiveRecord::Migration
  def up
    create_table :friend_apps do |t|
      t.integer :order_no, :default => 0
      t.string :app_name
      t.text :download_url
      t.string :icon_url
      t.text :description
      t.timestamps
    end
  end

  def down
    drop_table :friend_apps
  end
end
