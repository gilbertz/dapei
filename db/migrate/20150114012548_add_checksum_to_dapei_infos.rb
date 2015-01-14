class AddChecksumToDapeiInfos < ActiveRecord::Migration
  def change
    add_column :dapei_infos, :checksum, :string
  
    add_index :dapei_infos, :checksum
  end
end
