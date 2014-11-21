# encoding: utf-8

namespace :mall do
  
  task :dp, [:city_id] => :environment do |t, args|
    city_id = args[:city_id]
  end


  task :connect_shop => :environment do |t, args|
    Shop.where(:shop_type => 11).each do |s|
      if s.weibo and s.weibo != ""
        ct = CrawlerTemplate.find_by_source( s.weibo )
        s.mall_id = ct.mall_id if ct
        s.save
      else
        mall = Mall.find_by_city_id_and_name(s.city_id, s.name)
        if mall
          p s,mall
          s.mall_id = mall.id
          s.save 
        end
      end
    end
  end

  task :to_shop => :environment do |t, args|
     malls = Mall.all.each do |mall|
       p mall
       next unless mall.city_id
       shop_dict = {:city_id => mall.city_id, :name => mall.name, :address => mall.address}
       shop_dict[:shop_type] = 11
       shop_dict[:level] = 1
       shop_dict[:mall_id]
       if mall.shops.length >0 
         shop = mall.shops.first
         shop_dict["address"] = shop.address
         shop_dict["jindu"] = shop.jindu
         shop_dict["weidu"] = shop.weidu
       end

       if ct = CrawlerTemplate.find_by_mall_id( mall.id  )
         shop_dict[:weibo] = ct.source
       end
       s = Shop.new(shop_dict)
       s.save
     end
  end


  task :link_shop, [:city_id] => :environment do |t, args|
    city_id = args[:city_id]
    p "city_id", city_id
    cur_city = Area.city(city_id).first
    city_name = cur_city.name
    area_names = []
    area_names << city_name
    Area.dist(city_id).each do |area|
      area_names << area.name
    end

    malls = Mall.where(:city_id => city_id).order("dispose_count desc")
    pat_hash = {}
    name_hash = {}
    malls.each do |mall|
      if mall.pattern
        p mall.name, mall.pattern
        pat_hash[mall.id] = mall.pattern.strip
        name_hash[mall.id] = mall.name   
      end
    end
    shops = Shop.where(:city_id => city_id)
    shops.each do |s|
        if s
            next if s.mall_id.to_i > 0
            parts = s.name.split(/[()（）]+/)
            ali = parts[0]

            hit = false
            pat_hash.each do |k,v|
               if s.address
                  #print k,"->",v, "\n"
 
                  pats = v.split(/#/)
                  match = false
                  pat_num = 0
                  pats.each do |pat|
                    pp = "#{pat}".force_encoding("ASCII-8BIT")
                    area_names.each do |name|
                      pat = pat.gsub(/#{name}/, "")
                    end                    
                    if pat_num >0  and ( not pp.match(/#{$street_pat}/) or not pp.match(/\d+/) )
                      #p "!!!! " + pat
                      next
                    end
                    pat_num += 1
                    #p pat
                    if pat != ""
                      ks = pat.split(/\|/)
                      hit = true
                      ks.each do |t|
                        if not s.address.index(t) and not s.name.index(t)
                          hit = false
                          break
                        end
                      end
                      if hit 
                        match = true
                        break
                      end
                    end
                  end

                  if not match
                     next
                  end
                  p s.name
                  print pats, "->", v,"->",s.address, "\n"

                  s.mall_id = k
                  if s.mall_id and s.mall_id != 0
                      ali = ali + "(#{name_hash[s.mall_id]}店)"
                      print "!!sub,", s.name, '->', ali, "\n"
                      s.street = name_hash[s.mall_id]
                  end
                  hit = true
                  break
               end
            end
            if not hit
               #print "street !!!", s.address, '->', s.street, "\n"
               if s.street != ""
                  ali = ali + "(#{s.street}店)"
               end
            end
            #print "!!sub,", s.name, '->', ali, "\n"
            s.alias = ali
            s.save
        end
    end
  end


  task :pattern, [:city_id] => :environment do |t, args|
    city_id = args[:city_id]
    malls = Mall.where(:city_id => city_id )
    mall_fn  = Rails.root + 'db/seed/mall.list'
    mall_file = File.new( mall_fn )
    malls = []
    mall_file.each do |line|
      #malls << line.strip
      hash = Hash.new
      kv = line.strip.split(/[\t ]+/)
      pat = kv[0].strip
      mall = kv[-1].strip
      print mall, "->" ,pat, "\n"
      m = Mall.find_by_name_and_city_id(mall, city_id)
      if not m
        m = Mall.new(:name => mall, :city_id=>city_id)
      end  
      #m = Mall.find_by_name(mall)
      p m
      if m
        if not m.pattern
          m.pattern = ""
        end
        p m.pattern
        if not m.pattern.index(pat)
          m.pattern =  m.pattern + "#" + pat
        end
        if not m.pattern.index(mall)
          m.pattern =  m.pattern + "#" + mall
        end 
        p "!!!!" +m.pattern
        m.save
      end
    end
  end
end
