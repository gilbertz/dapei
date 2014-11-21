# -*- encoding : utf-8 -*-
class AddLikesCountToUser < ActiveRecord::Migration
  def change
    add_column :users, :likes_count, :string, :default=>0
  end
end
