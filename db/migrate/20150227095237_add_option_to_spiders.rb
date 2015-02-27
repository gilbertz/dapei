class AddOptionToSpiders < ActiveRecord::Migration
  def change
    add_column :spiders, :use_product_page, :boolean
    add_column :spiders, :product_img, :string
    add_column :spiders, :product_title, :string
  end
end
