# -*- encoding : utf-8 -*-
class CreateUserBehaviours < ActiveRecord::Migration
  def change
    create_table :user_behaviours do |t|
      t.integer  :user_id  
      t.text     :request_url
      t.string   :token 
      t.string   :ip_address 
      t.datetime :request_time

      t.timestamps
    end
  end

end
