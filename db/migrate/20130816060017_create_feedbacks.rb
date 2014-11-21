# -*- encoding : utf-8 -*-
class CreateFeedbacks < ActiveRecord::Migration
  def up
    create_table :feedbacks do |t|
      t.integer :user_id
      t.text :content
      t.string :qq
      t.string :email
      t.string :telephone
      t.timestamps
    end
  end

  def down
    drop_table :feedbacks
  end
end
