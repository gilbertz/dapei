# -*- encoding : utf-8 -*-
class ChangeColumnFlagType < ActiveRecord::Migration
  def up
    # remove_column :typesets, :flag_type
    add_column :typesets, :typeset_type_id, :integer
  end

  def down
    # add_column :typesets, :flag_type
    remove_column :typesets, :typeset_type_id
  end
end
