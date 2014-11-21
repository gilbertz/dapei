# -*- encoding : utf-8 -*-
class CreateWinners < ActiveRecord::Migration
  def up
    create_table :winners do |t|
      t.integer :user_id
      t.string :real_name
      t.string :address
      t.string :phone
      t.integer :win_what
      t.string :mark
      t.timestamps
    end
  end

  def down
    drop_table :winners
  end
end
