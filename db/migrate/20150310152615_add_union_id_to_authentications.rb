class AddUnionIdToAuthentications < ActiveRecord::Migration
  def change
    add_column :authentications, :fid, :string
  end
end
