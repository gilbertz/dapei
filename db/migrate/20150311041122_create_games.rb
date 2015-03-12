class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.integer :ibeacon_id
      t.integer :shop_id
      t.string :app_id
      t.string :game_id

      t.timestamps
    end
  end
end
