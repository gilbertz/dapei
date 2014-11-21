# -*- encoding : utf-8 -*-
class CreateRelations < ActiveRecord::Migration
  def change
    create_table :relations do |t|
      t.integer :item_id
      t.string :target_type
      t.integer :target_id

      t.timestamps
    end

    add_index  :relations, :item_id
    add_index  :relations, [:target_type, :target_id]
    add_index  :relations, [:item_id, :target_type, :target_id]
  end
end
