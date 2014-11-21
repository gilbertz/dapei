# -*- encoding : utf-8 -*-
class CreateLikeCountUsers < ActiveRecord::Migration
  def up
    create_table :like_count_users do |t|
      t.integer :user_id
      t.timestamps
    end
  end

  def down
    drop_table :like_count_users
  end
end
