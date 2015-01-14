class AddIndexToTagInfos < ActiveRecord::Migration
  def change
    add_index :tag_infos, [:dapei_id, :matter_id]
  end
end
