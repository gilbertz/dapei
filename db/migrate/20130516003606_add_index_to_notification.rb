# -*- encoding : utf-8 -*-
class AddIndexToNotification < ActiveRecord::Migration
  def change
    add_index :notifications, :type
    add_index :notifications, :notified_object_id
    add_index :notifications, :notified_object_type
    add_index :notifications, :sender_type
    add_index :notifications, :sender_id   
    add_index :receipts, :is_read 
    add_index :receipts, :trashed
    add_index :receipts, :deleted
    add_index :receipts, :mailbox_type
    add_index :receipts, :receiver_id
    add_index :receipts, :receiver_type
 
  end
end
