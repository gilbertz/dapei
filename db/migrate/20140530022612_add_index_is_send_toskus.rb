# -*- encoding : utf-8 -*-
class AddIndexIsSendToskus < ActiveRecord::Migration
  def up
    add_index :photos, [:is_send, :target_id, :target_type]
  end

  def down
    remove_index :photos, [:is_send, :target_id, :target_type]
  end
end
