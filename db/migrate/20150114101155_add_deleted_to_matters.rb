class AddDeletedToMatters < ActiveRecord::Migration
  def change
    add_column :matters, :deleted, :boolean

    add_index :matters, :deleted
  end
end
