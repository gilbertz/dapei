# -*- encoding : utf-8 -*-
class AddIndexToGameCategory < ActiveRecord::Migration
  def change
    add_index :game_images, [:viewable_id, :viewable_type]
    add_index :game_answers, [:viewable_id, :viewable_type]
  end
end
