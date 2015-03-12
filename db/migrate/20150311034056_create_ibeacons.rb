class CreateIbeacons < ActiveRecord::Migration
  def change
    create_table :ibeacons do |t|
      t.string :beaconid
      t.string :url
      t.integer :user_id
      t.integer :pv
      t.integer :uv

      t.timestamps
    end
  end
end
