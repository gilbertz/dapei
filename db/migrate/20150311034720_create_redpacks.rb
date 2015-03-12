class CreateRedpacks < ActiveRecord::Migration
  def change
    create_table :redpacks do |t|
      t.integer :ibeacon_id
      t.string :app_id
      t.integer :shop_id
      t.string :sender_name
      t.string :wishing
      t.string :action_title
      t.string :action_remark
      t.integer :min
      t.integer :max

      t.timestamps
    end
  end
end
