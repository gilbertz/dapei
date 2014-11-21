# -*- encoding : utf-8 -*-
class CreateDarenApplies < ActiveRecord::Migration
  def change
    create_table :daren_applies do |t|
      t.integer :user_id
      t.string :mobile
      t.string :qq
      t.string :address
      t.text :reason
      t.integer :photo1_id
      t.integer :photo2_id
      t.integer :photo3_id
      t.integer :status

      t.timestamps
    end
  end
end
