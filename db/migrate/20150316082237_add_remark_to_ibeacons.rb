class AddRemarkToIbeacons < ActiveRecord::Migration
  def change
    add_column :ibeacons, :remark, :string
  end
end
