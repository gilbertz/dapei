class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :ibeacon_id
      t.string :app_id
      t.string :card_id
      t.boolean :on
      t.integer :shop_id

      t.timestamps
    end
  end
end
