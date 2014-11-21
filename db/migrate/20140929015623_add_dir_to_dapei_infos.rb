class AddDirToDapeiInfos < ActiveRecord::Migration
  def change
    add_column :dapei_infos, :dir, :string
  end
end
