class AddUidToIbeacons < ActiveRecord::Migration
  def change
    add_column :ibeacons, :uid, :string
    add_index :ibeacons, :uid
  end
end
