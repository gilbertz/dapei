# -*- encoding : utf-8 -*-
class CreateFiveOnes < ActiveRecord::Migration
  def up
    create_table :five_ones do |t|
      t.integer :user_id
      t.integer :lucky_code
      t.timestamps
    end
  end

  def down
    drop_table :five_ones
  end
end
