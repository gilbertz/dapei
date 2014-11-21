# -*- encoding : utf-8 -*-
class CreateUserExts < ActiveRecord::Migration
  def change
    create_table :user_exts do |t|
      t.integer :user_id
      t.string :wx_gz_id
      t.string :baidu_push_id
      t.integer :cj_num_1

      t.timestamps
    end
  end
end
