class CreateBshows < ActiveRecord::Migration
  def change
    create_table :bshows do |t|
      t.integer :ibeacon_id
      t.string :url
      t.string :title
      t.integer :pv
      t.integer :uv
      t.string :weight
      t.boolean :on

      t.timestamps
    end
  end
end
