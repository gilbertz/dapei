# encoding: utf-8


  def simplify(s)
    s = s.downcase
    s.gsub /[^\w]/, ''
  end



  def process_brand_city(brand, city, hit_cities)
    city_name = city.name
    [brand.c_name, brand.e_name, brand.get_display_name].uniq.each do |query|
        page_num = 0
        while true
          break unless query
          break if  query == ""
          p "page=#{page_num}", query
          kd = { :ak => "990b06ceb651b2a2ef46ebd574a5fd2b" }

          res = RestClient.get "http://api.map.baidu.com/place/v2/search", {:params => {:q => query, \
            :output => "json", :region => city_name, :page_size => 20, :page_num => page_num }.merge(kd) }
          begin
            res = JSON.parse(res.gsub("&", " "))
          rescue => e
            p e.to_s
            page_num += 1
            next
          end
          sleep 2
          p res
          if res["status"] == 0 and res["results"]
            skip = false
            res["results"].each do |s|
                if s['address']
                  p "checking...", s['address'], s['name']
                  next unless brand.is_match_shop(s['name'])
                  p "pass checking"

                  name = s['name']
                  address = s['address']
                  lng = s['location']['lng']
                  lat = s['location']['lat']
                  tel = s['telephone']
                  uid = s['uid']
                  print "!!!!bd", s['name'], s['address'], lng, lat, uid,"\n"
                  searcher = Searcher.new(city.city_id, "shop", "", "near", 10, 1, nil, nil, lng, lat, brand.id)
                  near_shop = searcher.search().first
                  p "dis=", near_shop.distance, near_shop.shop_name if near_shop
                  if not near_shop or ( near_shop.distance.to_i > 1000 and  near_shop.distance.to_i < 50000)
                    unless Shop.find_by_bd_uid(uid)
                      p  "!!!!new shop"
                      begin
                        ns = Shop.new(:name => name, :phone_number => tel, :city_id =>city.city_id,  :address => address, :jindu =>lng, :weidu => lat, :bd_uid => uid)
                        ns.url = (name + Shop.maximum('id').to_s).to_url.to_url
                        ns.save!
                        p ns.id
                      rescue => e
                        p e.to_s
                        next
                      end
                    else
                      p "!!! to be updated"
                      os = Shop.find_by_bd_uid(uid)
                      os.update_attributes(:name => name, :phone_number => tel, :city_id =>city.city_id,  :address => address, :jindu =>lng, :weidu => lat, :bd_uid => uid)
                    end
                  end
                else
                  cityname = s["name"].gsub("市", "")
                  hit_cities << cityname if not hit_cities.include?(cityname)
                  skip = true
                end
            end
            if res["results"].length < 20 or skip
              break
            else
              page_num += 1
            end
          end
        end
    end
  end



namespace :seed do
  task :from_baidu_city, [:city_id] => :environment do |t, args|
    city_id = args[:city_id]
    city = Area.city(city_id).first
    hit_cities = []
    p city
    Brand.where("level >= 3").each do |brand|
      process_brand_city(brand,city, hit_cities)
    end
  end

  task :from_baidu_brand, [:brand_id] => :environment do |t, args|
    brand_id = args[:brand_id]
    brand = Brand.find(brand_id)
    hit_cities = []
    p brand
    Area.online_cities.each do |city|
      process_brand_city(brand, city, hit_cities)
    end 
  end

  task :from_baidu => :environment do
    done_brands = [] 
    done_fn= "/var/www/shangjieba/log/done_brand.list"
    File.new(done_fn).each do |line|
      done_f  = line.strip()
      done_brands << done_f
    end

    p done_brands

    Brand.where("level >= 3").each do |b|
      p  b.id, b.get_display_name, done_brands
      if done_brands.include?(b.id.to_s)
        next
      end
      hit_cities = []
      Area.online_cities.each do |city|
        break if city.city_id >= 350
        
        if hit_cities.length > 0 and not hit_cities.include?(city.name)
          p hit_cities, city.name
          next 
        end

        p "!!!!", city.name
        city_name = city.name
        #addresses = []
        #b.shops.where( "shops.city_id = #{city.city_id }" ).each do |s| 
        #  if s
        #    addresses << s.address
        #    print s.level, s.shop_name, s.address, city_name, s.jindu, s.weidu, "\n"
        #  end
        #end
        
        process_brand_city(b, city, hit_cities)      
      end
      `echo "#{b.id}" >> #{done_fn}`
      #break
      end
  end
end
