# encoding: utf-8

namespace :sem do

 task :brand_csv => :environment do
     count = Brand.maximum('id').to_i
     file1 = File.open("/var/www/shangjieba_dat/brand_plan_unit.csv","w")
     file2 = File.open("/var/www/shangjieba_dat/brand_creative_plan_unit.csv","w")
     file3 = File.open("/var/www/shangjieba_dat/brand_keyword_plan_unit.csv","w")
     if true
       city = "上海"
       for id in (1..count+1) do
         b = Brand.find_by_id(id)
         if b and b.shops.length >= 1
           file1.puts "#{b.name},启用,1.0"
           title = "[多图]#{city}#{b.name}2013新款 专柜同步 - 上街吧"
           title1 = "[多图]#{city}2013新款 专柜同步 - 上街吧"
   
           visit_url = "http://www.shangjieba.com/item/_brand___#{b.get_name}.html"
           intro = "超多漂亮#{b.name}2013新品，专柜同步预览。"
           intro_s = "周边热店，热评，实时优惠活动同步上映"
           intro1 = "超多漂亮2013新品，专柜同步预览。"
           intro1_s = "周边热店，热评，实时优惠活动同步上映"
           file2.puts "auto, #{b.name}, #{title}, #{intro}, #{intro_s}, #{visit_url}, http://www.shangjieba.com, #{visit_url}, www.shangjieba.com, 启用"
           file2.puts "auto, #{b.name}, #{title1}, #{intro1}, #{intro1_s}, #{visit_url}, http://www.shangjieba.com, #{visit_url}, www.shangjieba.com, 启用"
           keywords = [b.e_name, b.c_name]
           extentions = ["2013","夏款","衣服","女装","上海","专柜","新款","新品","单品","款式", "2013新品"]
           keywords.each do |k|
             if k != ""
               extentions.each do |ext|
                 file3.puts "auto, #{b.name}, #{k}#{ext}, 精确, 1.0, , , 启用"
                 file3.puts "auto, #{b.name}, #{ext}#{k}, 精确, 1.0, , , 启用"
               end
             end
           end
         end
       end
     end
 end

 task :mall_csv => :environment do
     count = Mall.maximum('id').to_i
     File.open("/var/www/shangjieba_dat/mall.csv","w") do |file|
       for id in (1..count+1) do
         b = Mall.find_by_id(id)
         if b
           file.puts "#{b.name},启用,1.0"
         end
       end
     end
 end

 

end
