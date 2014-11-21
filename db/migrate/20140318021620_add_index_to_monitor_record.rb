# -*- encoding : utf-8 -*-
class AddIndexToMonitorRecord < ActiveRecord::Migration
  def change
    add_index :monitor_records, :created_at
    add_index :monitor_records, [:controller, :action]
  end
end
