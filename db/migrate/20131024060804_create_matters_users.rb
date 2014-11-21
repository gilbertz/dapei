# -*- encoding : utf-8 -*-
class CreateMattersUsers < ActiveRecord::Migration
  def up
    create_table :matters_users, :id => false do |t|
      t.integer :matter_id
      t.integer :user_id
    end
  end

  def down
    drop_table :matters_users
  end
end
