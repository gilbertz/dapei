# -*- encoding : utf-8 -*-
class CreateGameAnswers < ActiveRecord::Migration
  def change
    create_table :game_answers do |t|
      t.string   :title
      t.string   :img
      t.integer  :viewable_id
      t.string   :viewable_type

      t.timestamps
    end
  end
end
