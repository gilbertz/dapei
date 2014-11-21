#encoding: utf-8

  def simplify(s)
    s = s.downcase
    s.gsub /[^\w]/, ''
  end

  def chinesize(s)
    s = s.gsub /[^\u4e00-\u9fa5]/, ''
  end  


namespace :seed do
 
 task :shop_city => :environment do
     count = Shop.maximum('id').to_i
     for id in (1..count+1) do
         s = Shop.find_by_id(id)
         if s and s.city_id == nil
            s.city_id = 1
            s.save!
            p s.id, s.city_id
            #print s.city_id, s.city, s.id
         end
     end
 end


 
 task :link_dp_review => :environment do
   count = Shop.maximum('id').to_i
   for id in (1..count+1) do
     s = Shop.find_by_id(id)
     if not s
       next
     end
     last_comment_at  = Time.now
     if s.comments and s.comments.length > 0
       last_comment_at = s.comments.last.created_at
       #last_comment = s.comments.last.comment
     end
     if s.level.to_i > 1 and s.dp_id and s.dp_id != ""
       dp_reviews = Dianping.new.get_reviews(s.dp_id)
       dp_reviews["reviews"].each do |r|
         name = r['user_nickname']
         content = r['text_excerpt']
         ct = r['created_time']
         ti = Time.parse(ct)
         if 15.days.since(ti) > Time.now and ti > last_comment_at
           uname = "sjb#{Digest::MD5.hexdigest(name)}"
           email = "#{uname}@shangjieba.com"
           cu = User.find_by_email(email)
           cu = User.create(:name=>name, :email=>email, :password=>"fakeuser123", :real=>false ) unless cu         
           print email, cu, "\n"
           c = s.comments.create(:commentable_type=>"Shop", :commentable_id=>s.id, :comment=>content, :user_id=>cu.id)
           print s.url, "\t", s.id, "\t", s.shop_name, "\n"
         end
       end
     end 
   end 
 end
  
 task :link_comment => :environment do
     count = Shop.maximum('id').to_i
     for id in (1..count+1) do
         s = Shop.find_by_id(id)
         if s and s.level and ( s.level == -1 or s.level == 0 )
            if s.mall and s.mall != "" and s.brand_name != "" and s.comments_count >0
              ss = Shop.where(:mall=>s.mall, :brand_name=>s.brand_name ).where("level>1").last
              if ss and ss.url != s.url
                ns = ss
                print s.dp_id, s.url, s.name, s.mall, s.street, s.brand_name, " => ", ns.dp_id, ns.url, ns.name, ns.mall, ns.street, ns.brand_name, "\n"
                s.comments.each do |comment|
                  print "transfer comment"
                  comment.commentable_id = ss.id
                  comment.save!
                end
                if s.dp_id and s.dp_id != "" and s.dp_id and ss.dp_id.to_i <= 0 
                  print "reval dp_id=", s.dp_id, "\n"
                  ss.dp_id = s.dp_id
                  ss.save
                end
                #break
              end
            end
         end
     end

 end


 
 task :comment_dat => :environment do
     count = Shop.maximum('id').to_i
     for id in (1..count+1) do
         s = Shop.find_by_id(id)
         if s and s.comments
            print s.url, s.comments_count, "->"
            s.comments_count = s.comments.length
            print s.comments_count, "\n"
            s.save!
         end
     end

     count = Item.maximum('id').to_i
     for id in (1..count+1) do
         i = Item.find_by_id(id)
         if i and i.comments
            i.comments_count = i.comments.length
            i.save!
         end
     end
 end
  


 task :no_pic => :environment do
     count = Brand.maximum('id').to_i
     for id in (1..count+1) do
         b = Brand.find_by_id(id)
         if b
             b.skus.each do |sku|
	       if sku.photos.length == 0 
                 print "no sku for brand ", b.name, "\n"
                 #sku.destroy
               end
             end
          end
     end
     count =  Item.maximum('id').to_i
     for id in (1..count+1) do
         b = Item.find_by_id(id)
         if b
             if ( not b.sku_id or b.sku_id == 0 ) and not b.photos
                 print "no pic for item ", b.shop_name, b.url, "\n"
             end
         end
     end
 end


 task :shop_street => :environment do
     count = Shop.maximum('id').to_i
     bad_pat = "(卢湾区)(((.+?)(区|县)))"
     bad_pat1 = "(近郊近郊)"
     bad_pat2 = "(卢湾区近郊)"
     street_pat = "((.+?)(区|县))((.+?(路|道|街|巷)).*)"
     street_pat1 = "((.+?(路|道|街|巷)).*)"
     
     for id in (1..count+1) do
         s = Shop.find_by_id(id)
         if s and ( not s.street or s.street == "")
             #p "#{s.address}"
             if not s.address
                 next
             end
            
             if s.address.match(/^#{bad_pat}/) or s.address.match(/^#{bad_pat2}/)
                #print "###",bm[0],"-",bm[1],"-",bm[2],"\n"
                s.address = s.address.sub("卢湾区", "")
             end 

            
             if s.address.match(/^#{bad_pat1}/)
                s.address = s.address.sub("近郊", "")
             end

             
             address = s.address  
             m = address.match(/^#{street_pat}/)
             if m
                 #p (m[4]+ " " + m[5]+" " + m[6]).force_encoding("UTF-8")
                if s.street == "" or not s.street
                    s.street =  m[5]
                end
             else
                 #p "#{s.address}"
                 n = address.match(/^#{street_pat1}/)
                 if n
                     #p "xxx", n, n[1], n[2], n[3], n.length
                     #p "ooo", s.get_dist_name
                     if not s.address.index(s.get_dist_name)
                         s.address = s.get_dist_name + s.address
                     end
                     s.street  = n[2]
                     s.street = s.street.sub("近郊","")
                     p "!!!!fix", s.address, s.street
                 end
             end
             s.save
         end
     end
 end


 task :shop_list => :environment do
     count = Shop.maximum('id').to_i
     s = "/var/www/shangjieba_dat/shop.list"
     File.open("#{s}","w") do |file|
       for id in (1..count+1) do
         s = Shop.find_by_id(count-id)
         if not s or (s.level and s.level < 1)
           next
         end
         if s.brand and s.url
	   file.puts "#{s.url}\t#{s.mall}\t#{s.brand.id}\t#{s.brand.e_name}\t#{s.brand.c_name}\t#{s.mall_id}"
         elsif s.url
           file.puts "#{s.url}\t#{s.mall}\t0\t#{s.display_name}\t\t#{s.mall_id}" 
         end
       end
     end
     upload = "/var/www/shangjieba/upload.exp"
     target = "/home/wanhuir/nealni/weibo"
     `#{upload} wanhuir.com wanhuir wan123 36000 #{s} #{target} 300`
 end


 task :brand_list1 => :environment do
     s = "/var/www/shangjieba_dat/brand.list"
     File.open("#{s}","w") do |file|
       Brand.where("level >= ? ", 3).order("skus_count DESC").each do |s|   
         if s
           file.puts "#{s.id}\t#{s.e_name}\t#{s.c_name}"
         end
       end
     end
     upload = "/var/www/shangjieba/upload.exp"
     target = "/home/wanhuir/nealni/weibo"
     `#{upload} wanhuir.com wanhuir wan123 36000 #{s} #{target} 300`
 end



 
 task :brand_list => :environment do
     count = Brand.maximum('id').to_i
     s = "/var/www/shangjieba_dat/brand.list" 
     File.open("#{s}","w") do |file|
       for id in (1..count+1) do
         s = Brand.find_by_id(id)
         if s
           file.puts "#{s.id}\t#{s.e_name}\t#{s.c_name}"
         end
       end
     end
     upload = "/var/www/shangjieba/upload.exp"
     target = "/home/wanhuir/nealni/weibo"
     `#{upload} wanhuir.com wanhuir wan123 36000 #{s} #{target} 300` 
 end



 task :fill_street_mall => :environment do
     count = Shop.maximum('id').to_i
     for id in (1..count+1) do
         s = Shop.find_by_id(id)
         if s and s.street and s.street != ""
            Street.create(:name => s.street) unless Street.find_by_name(s.street)
            p s.street
         end
         if s and s.mall and s.mall != ""
            mall = Mall.find_by_name(s.mall)
            print "!!!", s.mall, "\n"
            if mall
              p mall, mall.id
              s.mall_id = mall.id
            else
              mall = Mall.create(:name => s.mall)
              s.mall_id = mall.id
              p s.mall
            end
            s.save
         end
     end
 end


 task :default_sku => :environment do
     count = Item.maximum('id').to_i
     for id in (1..count+1) do
         i = Item.find_by_id(id)
         if i and i.sku_id == nil
           i.sku_id = i.id + 100000000
           i.save!
           p i.sku_id
         end
     end
 end

 task :link_brand => :environment do
     count = Brand.maximum('id').to_i
     brand_hash = Hash.new
     for id in (1..count+1) do
         brand = Brand.find_by_id(id)
         if brand
           name = brand.name
           bn = name.downcase
           en =  simplify(name)  
           cn =  chinesize(name)
           brand.e_name = en
           brand.c_name = cn
           brand.save
           print en,"\t",cn,"\t",bn,"\n"
           brand_hash[bn] = brand.id
           if en != "" and en.length >= 2 and not /^\d+$/.match(en)
             brand_hash[en] = brand.id
           end
           if cn != "" and cn != "区"
             brand_hash[cn] = brand.id
           end
         end
     end
     
     count = Shop.maximum('id').to_i
     for id in (1..count+1) do
         s = Shop.find_by_id(count-id+1)
         #if s and (not s.brand or s.brand_id == 0)
         if s
            sname = s.name.split(/[()（）]+/)[0]
            #sname = sname.gsub(/专卖|内衣|男装|店/, "")
            sn = sname.downcase
            en =  simplify(sname)
            cn =  chinesize(sname)
            #print en,"\t",cn,"\t",sname,"\t",s.url,"->",brand_hash[en],"\n"
            if brand_hash.has_key?(sn)
               s.brand_id = brand_hash[sn]
               brand = Brand.find_by_id(s.brand_id)
               s.brand_name = brand.e_name +  brand.c_name
               s.category_id = brand.category_id
               s.save
               print "!link ", s.name, "\t", s.url, "->", s.brand_name, "\t", sn,"\t", brand_hash[sn], "\n"
               next
            end


            if brand_hash.has_key?(en)
               s.brand_id = brand_hash[en]
               s.brand_name = Brand.find_by_id(s.brand_id).name
               s.category_id = brand.category_id
               s.save
               print "link ", s.name, "\t", s.url, "->", s.brand_name, "\t", en,"\t", brand_hash[en], "\n"
               next
            end
           
            if brand_hash.has_key?(cn)
               s.brand_id = brand_hash[cn]
               s.brand_name = Brand.find_by_id(s.brand_id).name
               s.category_id = brand.category_id
               s.save
               print "link ", s.name, "\t", s.url, "->", s.brand_name, "\t", cn, "\t", brand_hash[cn], "\n"
               next
            end
            print "unlink ", s.name, "\t", s.url, "->", cn, "\t", en, "\n"
         end
     end
  
 end


 task :sync_brand_sku => :environment do
     count = Shop.maximum('id').to_i
     for id in (1..count+1) do
         s = Shop.find_by_id(count-id+1)
         if s
           print 'sync brand sku', s.name, s.brand_id,"\n"
           s.sync_brand_sku(rand(6)+10)
         end
     end
 end

 task :sync_brand, [:brand_id] => :environment do |t, args|
     puts args[:brand_id]
     brand = Brand.find_by_id(args[:brand_id])
     brand.shops.each do |s|
       print s
       s.sync_brand_sku(200)
     end
 end

 task :sync_brand_shop_sku, [:brand_id] => :environment do |t, args|
     puts args[:brand_id]
     brand = Brand.find_by_id(args[:brand_id])
     brand.shops.each do |s|
       print s
       s.sync_all_sku(200)
     end
 end


 task :sync_item_sku => :environment do
     count = Item.maximum('id').to_i
     for id in (1..count+1) do
         s = Item.find_by_id(count-id+1)
         if s
           if s.sku_id and s.sku_id != "0"
              if not s.sku
                 print 'delete item', s.id, "\t", s.url, s.name, s.sku_id,"\n"
                 s.destroy
              end
           end
         end
     end
 end 


 task :fix_girdear => :environment do
     count = Item.maximum('id').to_i
     for id in (1..count+1) do
         s = Item.find_by_id(count-id+1)
         if s and s.sku and s.sku.brand_id == 117
            p s.id
            p s.url, "=>"
            s.url = s.url.to_url
            p s.url
            s.save
         end
     end
 end


 task :sync_all_sku => :environment do
     count = Shop.maximum('id').to_i
     for id in (1..count+1) do
         s = Shop.find_by_id(id)
         if s
           print 'sync all sku', s.name, s.brand_id
           s.sync_all_sku()
         end
     end
 end

 
 task :activate_comment => :environment do
     count = Shop.maximum('id').to_i
     for id in (1..count+1) do
         s = Shop.find_by_id(id)
         if s
           comments = s.comments
           if comments
              comments.each do |c|
                 if c.id <= 26000
                    p c.id
                    days = (DateTime.now.to_i - c.updated_at.to_i).to_i/86400
                    hours = ( (DateTime.now.to_i - c.updated_at.to_i).to_i/3600)%24
                    incr_day = rand(days.to_i) - 1
                    incr_hour = hours.to_i - 8 + rand(8)
                    incr_second = rand(1800)
                    updated_at = incr_day.days.since(c.updated_at)
                    updated_at = incr_hour.hours.since(c.updated_at)
                    updated_at = incr_second.seconds.since(c.updated_at)
                    print c.updated_at, '--->', updated_at
                    c.updated_at = updated_at
                    c.save 
                 end 
              end
           end
         end
     end

     #for n in 1..5 do
     #   cid = rand(26000) + 1
     #   comment = Comment.find_by_id(cid)
     #   print cid
     #   if comment
     #      comment.title =  Time.now.strftime("%Y-%m-1")
     #      comment.save 
     #   end
     #end
 end 


 task :shop_address => :environment do
  address_fn  = Rails.root + 'db/seed/shop_address.dat'
  address_file = File.new( address_fn )
  address_file.each do |line|
    items = line.strip().split(/\t| +/)
    dp_id = items[0].split('/').last
    address = items[1]
    #p dp_id, address
    shop = Shop.find_by_dp_id(dp_id)
    if shop and shop.address != address
       shop.address = address
       shop.save!
    end
  end
 end

 
 task :mall => :environment do
    mall_fn  = Rails.root + 'db/seed/mall.list'
    mall_file = File.new( mall_fn )
    malls = []
    mall_file.each do |line|
      #malls << line.strip
      hash = Hash.new
      kv = line.strip.split(/[\t ]+/)
      hash['k'] = kv[0]
      hash['v'] = kv[-1]
      print hash['k'], hash['v'], "\n"
      if hash['k'] 
        malls << hash
      end
    end
    count = Shop.maximum('id').to_i
    for id in (1..count+1) do
        s = Shop.find_by_id(id)
        #if s and (not s.mall or s.mall == "")
        if s
            parts = s.name.split(/[()（）]+/)
            ali = parts[0] 

            #if parts.length > 1
            #  p parts[-1].sub("店", "")
            #end
            
            hit = false
            for mall in malls
               if s.address and mall
                  k = mall['k']
                  v = mall['v']
                  ks = k.split(/\|/)

                  match = true
                  ks.each do |t|
                     if not s.address.index(t)
                        match = false
                        break
                     end
                  end
                  
                  if not match
                     next
                  end 
                  s.mall = v
                  if s.mall != ""
                      ali = ali + "(#{s.mall}店)"
                      s.street = v
                  end
                  hit = true
                  break
                  #s.save!
               end
            end
            if not hit
               print "street !!!", s.address, '->', s.street, "\n"
               if s.street != ""
                  ali = ali + "(#{s.street}店)" 
               end
            end
            print "!!sub,", s.name, '->', ali, "\n"
            s.alias = ali
            s.save
        end
    end
 end


 task :rand_like_shop => :environment do
    sc = Shop.maximum('id').to_i
    for id in (1..sc+1) do
        s = Shop.find_by_id(id)
        #if s and s.likes_count < 50
        if s 
            to_like_num = rand(2)
            for n in (1..to_like_num)
                uid = rand(29500)
                user = User.find_by_id(uid)
                if user
                    p user.name, 'like shop', s.url
                    user.like!('Shop', s.url)
                end
            end
        end
    end
    
 end

 
 task :rand_like_item => :environment do
    ic = Item.maximum('id').to_i
    for id in (1..ic+1) do
        s = Item.find_by_id(ic-id)
        #if s and s.likes_count < 10
        if s  
            to_like_num = rand(2)  
            for n in (1..to_like_num)
                uid = rand(29500)
                user = User.find_by_id(uid)
                if user
                  p user.name, 'like item:', s.url
                  user.like!('Item', s.url)
                end
            end
        end
    end
 end

 task :rand_like_dapei => :environment do
    Dapei.where( "category_id = 1001 and likes_count < 10").order("created_at desc").each do |s|
        if s
            to_like_num = rand(100)
            for n in (1..to_like_num)
                uid = rand(29500)
                user = User.find_by_id(uid)
                if user
                  p user.name, 'like item:', s.url
                  user.like!('Item', s.url)
                end
            end
        end
    end
 end


 task :rand_follow => :environment do
    sc = User.maximum('id').to_i
    for id in (1..sc+1) do
        s = User.find_by_id(id)
        if s
            to_like_num = rand(id%3+1)
            for n in (1..to_like_num)
                uid = rand(29500)
                user = User.find_by_id(uid)
                if user and user.id != s.id
                    p user.name, 'follow user:', s.name
                    user.follow(s)
                end
            end
        end
    end
 end

 task :fix_dat => :environment do
    sc = Shop.maximum('id').to_i
    for id in (1..sc+1) do
        s = Shop.find_by_id(id)
        if s
            print "old:\t", s.url, "\t", s.name, "\t", s.comments_count,"\t", s.likes_count, "\t", s.dispose_count, "\n"
            old_dispose_count = s.dispose_count
            if s.comments_count > 20 or s.dispose_count > 3000
               new_comments_count = rand(20) + Math.log(s.comments_count.to_i) + s.likes_count.to_i/10 + rand(s.likes_count/10)
               diff = s.comments_count - new_comments_count
               if s.dispose_count > diff*20
                  s.dispose_count -= diff*25
               end
               s.comments_count = new_comments_count
            end
            if s.likes_count > 50 and s.likes_count < 60
               s.likes_count = 10 + rand(s.comments_count)*2 + rand(s.dispose_count/10)  
            end
            if s.dispose_count < s.likes_count + s.comments_count or s.dispose_count > 5000
               s.dispose_count = s.likes_count*( 2+rand(5) ) + s.comments_count*( 5 + rand(10) ) +  rand(20)
            end

            if s.dispose_count != old_dispose_count 
               index = "shop"
               key = "#{index}_#{s.url}"
               $redis.set(key, s.dispose_count)
               s.save
               print "new:\t", s.url, "\t", s.name, "\t", s.comments_count,"\t", s.likes_count, "\t", s.dispose_count, "\n"
            end
        end
    end
 end


 task :lnglat => :environment do
   shop_file  = Rails.root + 'db/seed/shop_data.yml'
   shop_list = YAML::load_stream( File.open( shop_file ) )
   shop_list.each do |d|
    #next
    d.each_pair do |key, shop|
      dp_id = shop['dp_url'].split('/').last
      s = Shop.find_by_dp_id(dp_id)
      if s and ( s.jindu == shop['jindu'] or s.jindu == "")
        print dp_id, "\t", s.address, "\t", s.url, "\n"
      end
    end
  end

 end

end
