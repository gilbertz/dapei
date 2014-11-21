# -*- encoding : utf-8 -*-
class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table "photos", :force => true do |t|     
      t.integer  "author_id", :null => false
      t.boolean  "public", :default => false, :null => false     
      t.boolean  "pending", :default => false, :null => false
      t.string   "target_type"
      t.integer  "target_id"
      t.text     "text"
      t.text     "remote_photo_path"
      t.string   "remote_photo_name"
      t.string   "random_string"
      t.string   "processed_image"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "unprocessed_image"
      t.integer  "height"
      t.integer  "width"  
    end
    add_index "photos", ["target_id", "target_type"]
  end

  def self.down
    drop_table "photos"
  end
end
