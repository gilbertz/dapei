class AddPageIdToMatters < ActiveRecord::Migration
  def change
    add_column :matters, :page_id, :integer
  end
end
