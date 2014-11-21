# -*- encoding : utf-8 -*-
class CreateThumbPhotos < ActiveRecord::Migration
  def up
    create_table :thumb_photos do |t|
      t.text :image
      t.timestamps
    end
  end

  def down
    drop_table :thumb_photos
  end
end
