class AddSiteIdToMatters < ActiveRecord::Migration
  def change
    add_column :matters, :brand_id, :integer
    add_column :matters, :spider_id, :integer
  
    add_index :matters, :brand_id
    add_index :matters, :spider_id
  end
end
