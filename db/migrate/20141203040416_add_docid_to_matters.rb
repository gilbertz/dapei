class AddDocidToMatters < ActiveRecord::Migration
  def change
    add_column :matters, :docid, :string
    add_index :matters, :docid
  end
end
