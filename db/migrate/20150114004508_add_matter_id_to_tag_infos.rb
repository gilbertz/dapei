class AddMatterIdToTagInfos < ActiveRecord::Migration
  def change
    add_column :tag_infos, :matter_id, :integer
  end
end
