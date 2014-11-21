# -*- encoding : utf-8 -*-
class CreateSkuPromotions < ActiveRecord::Migration
  def up
    create_table "sku_promotions", :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin' do |t|
      t.string   "promotion_id"
      t.string   "name"
      t.string   "item_id"
      t.datetime "start_time", :null=>true
      t.datetime "end_time",:null=>true
      t.float    "item_promo_price"
      t.references :sku
    end
  end

  def down
    drop_table "sku_promotions"
  end
end
