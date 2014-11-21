class AddImgIdxToRelations < ActiveRecord::Migration
  def change
    add_column :relations, :img_idx, :integer
  end
end
