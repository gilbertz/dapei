class AddIndexToNewTables < ActiveRecord::Migration
  def change
    add_index :ibeacons, :url
    add_index :ibeacons, :user_id
    add_index :ibeacons, :beaconid

    add_index :cards, :ibeacon_id
    add_index :cards, :card_id
    add_index :cards, :shop_id
    add_index :cards, [:ibeacon_id, :on]

    add_index :redpacks, :ibeacon_id
    add_index :redpacks, :shop_id

    add_index :games, :ibeacon_id
    add_index :games, :shop_id
  end
end
