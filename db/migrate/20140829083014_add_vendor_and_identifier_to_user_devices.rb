class AddVendorAndIdentifierToUserDevices < ActiveRecord::Migration
  def change
    add_column :user_devices, :vendor, :string
    add_column :user_devices, :identifier, :string
  end
end
