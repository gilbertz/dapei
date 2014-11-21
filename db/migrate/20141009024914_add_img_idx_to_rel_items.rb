class AddImgIdxToRelItems < ActiveRecord::Migration
  def change
    add_column :rel_items, :img_idx, :integer
  end
end
