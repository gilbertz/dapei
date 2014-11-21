# -*- encoding : utf-8 -*-
class CreateRecommends < ActiveRecord::Migration
  def change
    create_table :recommends do |t|
      t.string :recommended_type
      t.integer :recommended_id
      t.string :reason
      t.integer :point
      t.timestamps
    end
  end
end
