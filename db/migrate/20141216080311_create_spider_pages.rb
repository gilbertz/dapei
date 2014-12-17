class CreateSpiderPages < ActiveRecord::Migration
  def change
    create_table :spider_pages do |t|
      t.string :name
      t.string :link
      t.integer :category_id
      t.integer  :parent_id
      t.integer :brand_id
      t.integer :user_id

      t.timestamps
    end
  end
end
