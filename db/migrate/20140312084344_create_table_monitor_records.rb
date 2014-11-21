# -*- encoding : utf-8 -*-
class CreateTableMonitorRecords < ActiveRecord::Migration
  def up
    create_table :monitor_records do |t|

      t.string :controller
      t.string :action
      t.string :request_type
      t.string :request_params
      t.string :original_url
      t.string :remote_ip
      t.string :http_agent
      t.integer :user_id

      t.timestamps
    end
  end

  def down
    drop_table :monitor_records
  end
end
