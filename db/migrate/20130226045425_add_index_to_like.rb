# -*- encoding : utf-8 -*-
class AddIndexToLike < ActiveRecord::Migration
  def change
    add_index :likes, [:user_id, :target_id, :target_type]
  end
end
