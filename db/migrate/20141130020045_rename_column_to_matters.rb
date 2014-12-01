class RenameColumnToMatters < ActiveRecord::Migration
  def up
    rename_column :matters, :rule_category_id, :category_id 
  end

  def down
  end
end
