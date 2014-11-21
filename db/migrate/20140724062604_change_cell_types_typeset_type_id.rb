# -*- encoding : utf-8 -*-
class ChangeCellTypesTypesetTypeId < ActiveRecord::Migration
  def up
    remove_column :cell_types, :typeset_id
    add_column :cell_types, :typeset_type_id, :integer
  end

  def down
    add_column :cell_types, :typeset_id, :integer
    remove_column :cell_types, :typeset_type_id
  end
end
