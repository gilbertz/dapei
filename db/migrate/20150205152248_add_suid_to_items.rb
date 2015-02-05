class AddSuidToItems < ActiveRecord::Migration
  def change
    add_column :items, :suid, :integer
    add_index :items, :suid
  end
end
