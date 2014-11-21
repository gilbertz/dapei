class AddSkuInfoToMatter < ActiveRecord::Migration
  def change
    add_column :matters, :title, :string
    add_column :matters, :desc, :text
    add_column :matters, :price, :integer
    add_column :matters, :sub_category_id, :integer
    add_column :matters, :link, :string
    add_column :matters, :comments_count, :integer
    add_column :matters, :dispose_count, :integer
    add_column :matters, :head, :string
  end
end
