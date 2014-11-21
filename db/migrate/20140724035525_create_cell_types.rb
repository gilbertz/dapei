# -*- encoding : utf-8 -*-
class CreateCellTypes < ActiveRecord::Migration
  def up
    create_table :cell_types do |t|
      t.integer :type_num
      t.string :mark
      t.integer :width
      t.integer :height
      t.integer :typeset_id
    end

    add_index :cell_types, :typeset_id

  end

  def down
    drop_table :cell_types
  end
end
