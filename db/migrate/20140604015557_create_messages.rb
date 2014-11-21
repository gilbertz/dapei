# -*- encoding : utf-8 -*-
class CreateMessages < ActiveRecord::Migration
  def up
    create_table :messages do |t|
      t.integer :sender_id
      t.integer :accept_id
      t.text :content
      t.string :link_url
      t.timestamps
    end
  end

  def down
    drop_table :messages
  end
end
