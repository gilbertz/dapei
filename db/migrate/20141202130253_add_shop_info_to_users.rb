class AddShopInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :address, :string
    add_column :users, :apply_type, :integer
    add_column :users, :product_type, :integer
    add_column :users, :brand_id, :integer
    add_column :users, :site, :string
    add_column :users, :apply_status, :integer
    
    add_column :users, :contact, :string
    add_column :users, :photo1_id, :integer
    add_column :users, :photo2_id, :integer
    add_column :users, :photo3_id, :integer
   
  end
end
