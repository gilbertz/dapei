class CreateTagInfos < ActiveRecord::Migration
  def change
    create_table :tag_infos do |t|
      t.belongs_to :photo
      t.string :tag_type
      t.string :name
      t.string :coord ,:comment => '坐标'
      t.boolean :direction ,:comment => '方向'
      t.timestamps
    end
  end
end
