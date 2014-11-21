# -*- encoding : utf-8 -*-
class CreateUserDevices < ActiveRecord::Migration
  def change
    create_table :user_devices do |t|
      t.string :appid
      t.integer :user_id
      t.string :baidu_uid
      t.string :channel_id
      t.integer :device_type
      t.string :token

      t.timestamps
    end
    add_index :user_devices, :user_id
    add_index :user_devices, :baidu_uid
    add_index :user_devices, :channel_id
    add_index :user_devices, :device_type
    add_index :user_devices, :token
  end
end
