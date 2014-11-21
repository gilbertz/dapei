# -*- encoding : utf-8 -*-
class CreateGameImages < ActiveRecord::Migration
  def change
    create_table :game_images do |t|
      t.string  :title
      t.integer :viewable_id
      t.string  :viewable_type
      t.integer :state
      t.string  :body

      t.timestamps
    end
  end
end
