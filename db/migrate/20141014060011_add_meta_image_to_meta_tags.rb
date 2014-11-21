class AddMetaImageToMetaTags < ActiveRecord::Migration
  def change
    add_column :meta_tags, :meta_image, :string
  end
end
