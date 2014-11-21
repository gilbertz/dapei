# -*- encoding : utf-8 -*-
class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.integer :user_id
      t.string :provider
      t.string :uid
      t.string :access_token
      t.integer :expires_at

      t.timestamps
    end
  end
end
