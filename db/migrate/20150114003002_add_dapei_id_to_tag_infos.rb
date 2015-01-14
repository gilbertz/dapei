class AddDapeiIdToTagInfos < ActiveRecord::Migration
  def change
    add_column :tag_infos, :dapei_id, :integer
  end
end
