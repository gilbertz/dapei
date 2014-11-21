# -*- encoding : utf-8 -*-
class CreateSetCells < ActiveRecord::Migration
  def up
    create_table :set_cells do |t|
      t.integer :typeset_id #集合id
      t.integer :cell_type_id #单元 类型
      t.string :image
      t.integer :tag_id #指定标题的id
      t.timestamps
    end

    add_index :set_cells, :typeset_id
    add_index :set_cells, :cell_type_id
    add_index :set_cells, :tag_id

  end

  def down
    drop_table :set_cells
  end
end
