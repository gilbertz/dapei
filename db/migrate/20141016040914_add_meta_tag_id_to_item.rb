class AddMetaTagIdToItem < ActiveRecord::Migration
  def change
    add_column :items, :meta_tag_id, :integer
  end
end
