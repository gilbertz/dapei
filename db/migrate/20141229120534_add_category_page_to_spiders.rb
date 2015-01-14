class AddCategoryPageToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :category_page, :string
  end
end
