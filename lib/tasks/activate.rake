#encoding: utf-8

namespace :shop do
  task :init_level => :environment do
     count = Shop.maximum('id').to_i
     for id in (1..count+1) do
        next if id < 190000
        p id if id%100 == 0
        s = Shop.find_by_id(count-id+1)
        if s
           if s.level and s.level >= 3
              p s.level
              s.level = 2
              p s.id, s.level
              s.save
           end  
        end
     end
  end   


  task :level_brand => :environment do
     count = Sku.maximum('id').to_i
     brand_hash = {}
     for id in (1..count+1) do
        break if id%10000 == 0
        sku = Sku.find_by_id(count-id+1)
        if sku and sku.brand
          if brand_hash[sku.brand.id]
            next
          else
            brand_hash[sku.brand.id] = true
          end

          if sku.from =~ /homepage/
            p brand.name
            brand.level = 5
            brand.save 
          end
        end
     end 
  end


  task :level_sku => :environment do
     brands = Brand.where("level >= 2")
     brands.each do |b|
        p b.name,b.level
        b.skus.each do |sku|
          sku.level_sku
        end  
     end
  end

  task :level_shop_by_brand => :environment do
     brands = Brand.where("level >= 2")
     brands.each do |b|
        p b.name,b.level
        b.shops.each do |s|
          if s and s.level.to_i >= 0
            s.level = b.level
            s.save
          end
        end
     end
 end
 
 
 task :sync_item_by_brand, [:brand_id] => :environment do |t, args|
     puts args[:brand_id]
     brand_id = args[:brand_id]
     if true
        b = Brand.find_by_id(brand_id)
        p b.name,b.level
        b.skus.each do |sku|
          sku.level_sku
          p sku.title, sku.level
        end
        b.shops.each do |s|
          s.sync_brand_sku(20)
        end
     end
 end 


 task :clear_duplicate_sku => :environment do
     Brand.where("level >= 3" ).each do |b|
        sku_hash = {}
        b.skus.each do |sku|
          next if sku.photos.length <= 0
          next if sku.from != "homepage"
          next if sku.buy_url == nil
          if sku.category_id > 100
            sku.deleted = nil
            sku.save
          end
          key = sku.docid.to_s + sku.title + sku.price.to_s + sku.pno.to_s + sku.from.to_s
          p key
          if sku_hash[key]
            p "!!!dupliate" + key
            sku.deleted = true
          else
            sku.deleted = nil
            sku_hash[key] = true
          end
          sku.save
        end
     end
 end


 task :clear_duplicate_sku_by_brand, [:brand_id] => :environment do |t, args|
     puts args[:brand_id]
     brand_id = args[:brand_id]
     if true
        b = Brand.find_by_id(brand_id)
        sku_hash = {}
        b.skus.each do |sku|
          next if sku.photos.length <= 0
          next if sku.from != "homepage"
          if sku.category_id > 100
            sku.deleted = nil
            sku.save
          end
          key = sku.title + sku.price.to_s + sku.pno.to_s
          p key
          if sku_hash[key]
            p "!!!dupliate" + key
            sku.deleted = true
          else
            sku.deleted = nil
            sku_hash[key] = true
          end
          sku.save
        end
     end
 end

 task :clear_duplicate_shop => :environment do
     Brand.where("level >= 3").each do |b|
        shop_hash = {}
        b.shops.each do |s|
          key = s.brand_id.to_s + "_" + s.address
          #p key, s.shop_name
          if shop_hash[key]
            p "!!!dupliate" + key
            p s.url, s.comments_count, s.level
            p "vs"
            s1 = Shop.find_by_url(shop_hash[key] )
            p s1.url, s1.comments_count, s1.level
            if s.comments_count.to_i <= s1.comments_count.to_i
              s.level = -1
              s.save
            end
          elsif s.level.to_i >= b.level
            shop_hash[key] = s.url
          end
        end
     end
 end


 task :sync_sku_by_brand, [:brand_id] => :environment do |t, args|
     puts args[:brand_id]
     brand_id = args[:brand_id]
     if true
        b = Brand.find_by_id(brand_id)
        p b.name, b.level
        b.skus.each do |sku|
          sku.level_sku
          p sku.level
        end
        b.shops.each do |s|
          p s.name
          s.sync_all_sku
          s.sync_brand_sku(20)
          if s.level.to_i >= 0
            s.level = b.level
            s.save
          end
        end
     end
 end


 task :sync_all_brand => :environment do 
      Brand.where("level >=3 ").order("id desc").each do |b|
        p b.name, b.level
        b.sync_shop
     end
 end


 task :upgrade_brand => :environment do
      Brand.where("level = 3 ").order("updated_at desc").each do |b|
        p b.name, b.level
        next if b.wide_avatar_url =~ /img.png/  
        next if b.white_avatar_url =~ /img.png/ 
        next if b.black_avatar_url =~ /img.png/ 
        next if b.wide_banner_url =~ /img.jpg/ 
        #next if b.shop_photo_url =~ /img.jpg/ 
        next if b.wide_campaign_imgs(:wide_small).length < 3
        last_sku = b.skus.where("skus.category_id < 100").order("created_at desc").first
        next unless last_sku
        if last_sku.from == nil or last_sku.from =~ /homepage/
          p b.name + 'set level to 5'
          b.level  = 5
          b.save
        else
          p "last sku status"
          p last_sku, last_sku.title, last_sku.level, last_sku.created_at
          next
        end

        b.sync_shop
     end
 end


 task :degrade_tmall_brand => :environment do
      Brand.where("level >=4 ").each do |b|
          if b.spiders.length > 0
            ct = b.spiders.order("created_at desc").first
            if ct.start_page =~ /tmall/
              p b.priority
              if b.priority
                b.priority = b.priority/2
              else
                b.priority = 2
              end
              p b.priority
              p ct.start_page
              b.save
            end
          end
      end
 end


 
 task :degrade_brand => :environment do
      Brand.where("level < 5 and level >=2").each do |b|
        p b.name, b.level
        b.skus.each do |sku|
          sku.level_sku
          p sku.level
        end
        b.shops.each do |s|
          s.sync_all_sku
          s.sync_brand_sku(100)
        end
     end
 end 

 task :level_by_sku => :environment do
     count = Sku.maximum('id').to_i
     brand_hash = {}
     for id in (1..count+1) do
        p id if id%100 == 0
        sku = Sku.find_by_id(count-id+1)
        if sku and sku.brand
          #if brand_hash[sku.brand.id]
          #  next
          #else
          #  brand_hash[sku.brand.id] = true
          #end
              
          if sku.from =~ /homepage/
            sku.brand.level = 6
            sku.brand.save
            sku.brand.shops.each do |s|
              if s.level <= 5
                p s.name, 5
                s.level = 6
                s.save
              end
            end
            sku.items.each do |item|
              item.level = 5
              item.save
            end  
          end
          if sku.from == "weibo"
            sku.brand.shops.each do |s|
              if s.level >= 2
                if sku.brand.level.to_i > 2 and sku.brand.level <= 5
                  p s.name, sku.brand.level, sku.from                   
                  if s.level < sku.brand.level 
                    s.level = sku.brand.level
                    s.save
                  end
                  sku.items.each do |item|
                    item.level =  sku.brand.level
                    item.save
                  end
                end
              end
            end 
          end
        end
     end
  end


  task :activate_from_brand, [:city_id] => :environment do |t, args|
    puts args[:city_id]
    shops = Shop.where(:city_id => args[:city_id] )
    shops.each do |s|
      if not s
        next
      end
      if s.brand
        s.level = 2
        s.save
      end
    end 
  end


  task :deactivate, [:city_id] => :environment do |t, args|
    puts args[:city_id]
    shops = Shop.where(:city_id => args[:city_id] )
    shops.each do |s|
      if not s
        next
      end
      if s.brand and s.photos.length ==0 and s.level >= 1 
        p s.level, s.url
        s.level= 0
        s.save
      end
    end
  end


  task :activate_all => :environment do
    count = Shop.maximum('id').to_i
    for id in (1..count+1) do
      p id
      s = Shop.find_by_id(count-id+1)  
      if not s
        next
      end
      if s.brand and s.level == 0 and s.city_id != 1
        s.level = 2
        p "activate ..." + s.brand.url
        s.save
      end
    end
  end


  task :activate, [:city_id] => :environment do |t, args|
    puts args[:city_id]
    shops = Shop.where(:city_id => args[:city_id] ) 
    shops.each do |s|
      if not s
        next
      end
      s.activate_from_dp
    end
  end

  task :activate_all_from_dp => :environment do 
    count = Shop.maximum('id').to_i
    for id in (1..count+1) do
      s = Shop.find_by_id(count-id+1)
      if not s
        next
      end
      s.activate_from_dp
    end
  end

  task :fix_hum_city => :environment do
    count = Shop.maximum('id').to_i
    online_cities = Area.online_cities
    for id in (1..count+1) do
      s = Shop.find_by_id(count-id+1)
      next if not s
      next if not s.city_id
      if s.city_id == 255 and not s.address.index("阿坝")
        p "xxx", s.name, s.city_id, s.address, s.jindu, s.weidu
        searcher = Searcher.new(0, "shop", "", "near", 10, 1, nil, nil, s.jindu, s.weidu)
        shops = searcher.search()
        rn = 0
        last = 0
        shops.each do |s|
          p "!!!", rn, s.city_id, s.name, s.address
          if s.city_id == last
            rn += 1
          else
            rn = 1
          end
          if rn >= 4
            p "#### set to new city=#{last}"
            s.city_id = last
            s.save!
            p s.city_id
            break
          end
          last = s.city_id
        end
        #online_cities.each do |city|
        #  if s.address.index(city.name)
        #    s.city_id = city.city_id
        #    p city.name, s.city_id
        #    s.save
        #    p s.city_id
        #  end
        #end
      end
    end
  end


  task :update_city_address => :environment do
    count = Shop.maximum('id').to_i
    for id in (1..count+1) do
      s = Shop.find_by_id(count-id+1)
      next if not s
      city_name = Area.city(s.city_id).first.name
      if not s.address.index(city_name)
        print s.name, s.address, s.city_id
        #if not a.address.index("市")
          s.address = city_name + "市"  + s.address
          p s.address
          s.save
        #end
      end
    end
  end

end
