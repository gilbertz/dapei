class AddCoverImageToItem < ActiveRecord::Migration
  def change
    add_column :items, :cover_image, :string
  end
end
