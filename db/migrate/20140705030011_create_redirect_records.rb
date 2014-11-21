# -*- encoding : utf-8 -*-
class CreateRedirectRecords < ActiveRecord::Migration
  def up
    create_table :redirect_records do |t|
      t.integer :user_id, :default => 0
      t.integer :sku_id
      t.string :request_ip
      t.timestamps
    end
  end

  def down
    drop_table :redirect_records
  end
end
