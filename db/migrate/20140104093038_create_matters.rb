# -*- encoding : utf-8 -*-
class CreateMatters < ActiveRecord::Migration
  def change
  
    create_table "matters" do |t|
      t.integer  "user_id"
      t.integer  "source_type"
      t.integer  "rule_category_id"
      t.integer  "color_one_id"
      t.integer  "color_two_id"
      t.integer  "color_three_id"
      t.string   "local_photo_name"
      t.string   "local_photo_path"
      t.string   "local_cut_photo_name"
      t.string   "local_cut_photo_path"
      t.string   "remote_photo_path"
      t.string   "remote_photo_name"
      t.integer  "sjb_photo_id"
      t.string   "height"
      t.string   "width"
      t.integer  "is_cut"
      t.datetime "created_at",           :null => false
      t.datetime "updated_at",           :null => false
      t.string   "image_name"
      t.integer  "sjb_item_id"
      t.integer  "sku_id"
      t.string   "tags"
      t.integer  "likes_count"
      t.integer  "level"
    end
                                                                                            
    add_index "matters", ["color_one_id"], :name => "index_matters_on_color_one_id"
    add_index "matters", ["color_three_id"], :name => "index_matters_on_color_three_id"
    add_index "matters", ["color_two_id"], :name => "index_matters_on_color_two_id"
    add_index "matters", ["image_name"], :name => "index_matters_on_image_name"
    add_index "matters", ["rule_category_id"], :name => "index_matters_on_rule_category_id"
    add_index "matters", ["sjb_photo_id"], :name => "index_matters_on_sjb_photo_id"
    add_index "matters", ["sku_id"], :name => "index_matters_on_sku_id"
    add_index "matters", ["user_id"], :name => "index_matters_on_user_id"
   
  end
end
