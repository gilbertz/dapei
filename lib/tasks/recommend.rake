require 'rest_client'
require 'json'

namespace :recommend do
  task :daily, [:city_id] => :environment do |t, args|
    p args[:city_id]
    city_id = args[:city_id]
    #shop_ids = Recommend.new.recommend("shop", city_id)
    #cids = [3, 4, 5, 6, 7, 8, 11, 12, 13, 14]
    #cids.each do |cid|
    #  p cid
    #  item_ids = Recommend.new.recommend("item", city_id, cid)
    #end
    #discount_ids = Recommend.new.recommend("discount", city_id)
    #dapei_ids =  Recommend.new.recommend("dapei", city_id)
    cids = [3, 4, 5, 6, 7, 8, 11, 12, 13, 14]
    cids.each do |cid|
        p cid
        item_ids = Recommend.new.recommend("sku", nil, cid)
        p "xxx", item_ids
    end
   
  end

  task :all_daily => :environment do
    (1..350).each do |city_id|
      shop_ids = Recommend.new.recommend("shop", city_id)
      discount_ids = Recommend.new.recommend("discount", city_id)
    end
    dapei_ids =  Recommend.new.recommend("dapei", city_id)
    cids = [3, 4, 5, 6, 7, 8, 11, 12, 13, 14]
    cids.each do |cid|
        p cid
        item_ids = Recommend.new.recommend("sku", city_id, cid)
        p item_ids
    end
  end
end
