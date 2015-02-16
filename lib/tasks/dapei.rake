# encoding: utf-8

namespace :dapei do
  task :cron_refresh  => :environment do
      Dapei.where( "category_id = 1001 or category_id = 1000").where("level <= -2").order("created_at desc").each do |s|
         p s
         if s.dapei_info.start_date and  s.dapei_info.start_date == Date.today
            t = Time.now
            p s.dapei_info
            if t.hour >= s.dapei_info.start_date_hour.to_i
              p s.dapei_info.start_date, s.dapei_info.start_date_hour
              s.created_at = t
              s.level = 2
              p s.created_at
              s.save
              s.rand_like
            end
         end
      end
  end


  task :cron_pv_notify  => :environment do
      Dapei.where( "category_id = 1001").order("created_at desc").limit(1000).each do |s|
        if s.get_user
          p s.get_user.url, s.url
          s.notify_pv
        end 
      end
  end


  task :cron_col_review  => :environment do
      key = "col_to_be_shown"
      num = 2
      Dapei.cron_review(key, num)
  end



  task :cron_review  => :environment do
      key = "dp_to_be_shown"
      num = 5
      Dapei.cron_review(key, num)
  end
  

  task :fill_matter  => :environment do
      Dapei.where("category_id = 1001").where( "level >=1 ").order("created_at desc").limit(500).each do |s|
          next unless s.dapei_info
          #next if s.dapei_info.tagged
          p s
          s.dapei_info.dapei_item_infos.each do |i|
              if i
                matter = i.get_matter
                next unless matter
                next unless matter.category_id <= 100
                matter.level = 10
                matter.dapeis_count = matter.get_dapeis_count 
                matter.save
                p matter
              end
          end

          #p tags
          #s.dapei_info.tagged = true
          #s.dapei_info.save
      end
  end
  


  task :sku_head  => :environment do
      Dapei.where("category_id = 1001").where( "level >=0 ").order("created_at desc").each do |s|
          next unless s.dapei_info
          next if s.dapei_info.tagged
          p s
          heads = []
          labels = []
          brands = ''
          s.dapei_info.dapei_item_infos.each do |i|
             heads << i.sku.head.to_s if i.sku
             brands += ' ' + i.sku.brand.get_describe if i.sku
             labels +=  i.sku.tags.split(/[, ]/) if i.sku and i.sku.tags
          end
          p heads,labels,brands
          
          tags = heads + labels
          tags += s.dapei_info.tags.split(/[, ]/) if s.dapei_info.tags
          p tags
          s.dapei_info.tags = tags.uniq.join(' ')
          p "=>", s.dapei_info.tags
          s.dapei_info.tagged = true
          s.dapei_info.description = s.dapei_info.description.to_s + brands
          s.dapei_info.save
      end
  end
  

  task :make_names  => :environment do
    names = []
    names_fn = Rails.root + "db/seed/names.txt"
    File.new(names_fn).each do |line|
      c  = line.strip()
      p c
      names << c
    end
    
    pat = /sh\d+/
    (1..30000).each do |i|
       u = User.find_by_id(i)
       next unless u
       p u.name, "=>"
       if pat.match( u.name ) or u.name == "sjb"
         idx = u.id % names.length
         u.name = names[idx]
         p u.name
         u.save 
       end
    end

  end
   
  task :rand_like_dapei => :environment do
    #Dapei.where( "category_id = 1001 and likes_count < 20 and level >= 2").order("created_at desc").limit(200).each do |s|
    Item.where( "category_id >= 1001 and likes_count < 20 and level >= 2").order("created_at desc").limit(200).each do |s|
       if s
            if s.likes_count < 20+rand(10)
              to_like_num = 10 + rand(20)

              for n in (1..to_like_num)
                uid = rand(29500)
                user = User.find_by_id(uid)
                if user
                  p user.name, 'like item:', s.url
                  user.like!('Item', s.url)
                  if s.get_user.followers_count < 200
                    user.follow( s.get_user )
                  end
                end
              end
            end
         end
       end
  end

 
  task :like_dapei => :environment do
    Dapei.where( "category_id = 1001 and level >=2 ").order("created_at desc").limit(20).each do |s|
       if s
            if true
              to_like_num = 50
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
  end

 
  task :like_dapei_fake => :environment do
    uids = []
    for n in (1..300)
      uid = rand(29500)
      uids << uid
    end

    dps = Dapei.where( "category_id = 1001 and level > 1" ).order("created_at desc").limit(100)
    dps.each do |dp|
      uids.each do |uid|
        u =  User.find_by_id(uid)
        if u 
          #p "#{u.name} like #{dp.title}"     
          u.like!('Item', dp.url)
        end
      end
    end
  end


  task :rand_comment_dapei => :environment do
    comments = []
    comment_fn = Rails.root + "db/seed/dapei_comments.txt"
    File.new(comment_fn).each do |line|
      p line
      c  = line.strip()
      comments << c
    end
    len = comments.length
    p "comenets num=#{len}"

    Dapei.where( "category_id = 1001 and comments_count <= 10 and level >= 2").order("created_at desc").limit(100).each do |s|
       if s
            if s.comments_count < 5+rand(8)
              cn = rand(2)
               for id in (1..cn) 
                uid = rand(29500)
                user = User.find_by_id(uid)
                 
                content = comments[rand(len)]
                p content
                if user
                  p user.name, 'coment item:', s.url
                  c = s.comments.new(:commentable_type=>"Item", :commentable_id=>s.id, :comment=>content, :user_id=>uid) 
                  c.save
                  c.created_at = c.created_at - rand(60).minutes
                  c.save
                  if s.get_user.followers_count < 200
                    user.follow( s.get_user )
                  end
                  p c
                end
              end
            end
         end
       end
   end



   task :clear_matter, [:brand_id] => :environment do |t, args|
     puts args[:brand_id]
     brand = Brand.find_by_id( args[:brand_id] )
     brand.skus.each do |sku|
       p sku
       Matter.find_all_by_sku_id(sku.id).each do |matter|
         #next unless 1.days.since(matter.created_at) > Time.now
         photo = Photo.find_by_id(matter.sjb_photo_id)
         next if not photo
         next if photo.is_send
         p matter
         matter.destroy
       end
     end
   end

   task :matter_cron_by_brand, [:brand_id] => :environment do |t, args|
     brand = Brand.find_by_id( args[:brand_id] ) 
     if brand
         if brand.level.to_i >= 5
             spider = brand.get_active_spider
             next unless spider
             if spider.pic_index
               p spider, spider.template_id
               brand.skus.each do |sku|
                 #p sku.buy_domain
                 next unless sku.category_id < 20
                 next unless 60.days.since(sku.created_at) > Time.now
                 if not sku.buy_domain.index( spider.spider_domain )
                   p sku.buy_domain
                   #Matter.where(:sku_id => sku.id).each do |m|
                   #  p sku
                   #  if  1.days.since(m.created_at) > Time.now
                   #    p m 
                   #    m.destroy
                   #  end
                   #end
                 else
                   sku.spider_id = spider.id
                   sku.save
                   #p sku.buy_domain + "  vs  " + spider.spider_domain
                   m = Matter.from_sku(sku, spider)
                   #p m.sku_id, s.sjb_photo_id if m
                 end
               end
             end
         end
     end
   end


   task :matter_cron => :environment do
     count = Brand.maximum('id').to_i
     for id in (1..count+1) do
         brand = Brand.find_by_id(count-id+1)
         if brand and brand.level.to_i >= 4 
             #p brand
             spider = brand.get_active_spider
             next unless spider
             #if spider.is_net_porter
             if spider.pic_index 
               p spider, spider.template_id
               brand.skus.each do |sku|
                 #p sku.buy_domain
                 next unless sku.category_id < 20
                 next unless 60.days.since(sku.created_at) > Time.now
                 if not sku.buy_domain.index( spider.spider_domain )
                   #p sku.buy_domain
                   #Matter.where(:sku_id => sku.id).each do |m|
                   #  p sku
                   #  if  1.days.since(m.created_at) > Time.now
                   #    p m 
                   #    m.destroy
                   #  end
                   #end
                 else
                   sku.spider_id = spider.id
                   sku.save 
                   #p sku.buy_domain + "  vs  " + spider.spider_domain
                   m = Matter.from_sku(sku, spider)
                   #p m.sku_id, s.sjb_photo_id if m
                 end
               end
             end
         end
     end
   end

   task :sync_sku => :environment do
     dapeis=Dapei.where(:category_id => "1001" ).order("created_at desc")
     dapeis.each do |dp|
       dp.dapei_info.dapei_item_infos.each do |r|
         r.sku.sync_to_shop unless r.sku.blank?
       end
     end
   end

   task :make_share_img => :environment do
     dapeis=Dapei.where(:category_id => "1001" ).where('id > 5496600').order("created_at desc")
     dapeis.each do |dp|
       dp.make_share_img if dp
     end
   end

   task :add_brand_tags => :environment do
    count = 0
    Dapei.all.each do |dapei|
      brands = Array.new
      dapei.get_skus.each do |sku|
        if sku
          brands <<sku.brand.display_name
        end
      end
      if dapei.dapei_info
        brands << dapei.dapei_info.tags
      end
      dapei.tag_list = brands
      dapei.save
      puts dapei.id
      puts count=count+1
    end
   end


   task :get_color => :environment do
     dapeis=Dapei.where(:category_id => "1001" ).order("created_at desc")
     #图片取色处理程序目录
     Image_dispose_color = "/var/ImageDispose/extract_color"
     dapeis.each do |dp|
      next unless dp
      next unless dp.dapei_info
      next if dp.dapei_info.color_one_id and dp.dapei_info.color_two_id and dp.dapei_info.color_three_id
      new_image_png = "/var/www/shangjieba/public/uploads/cgi/img-set/cid/#{dp.id}/id/#{dp.dapei_info.spec_uuid}/size/y.jpg"
      puts "get colors"
      puts "cd #{Image_dispose_color} && ./extract_color color1.txt #{new_image_png}"

      colors = `cd #{Image_dispose_color} && ./extract_color color1.txt #{new_image_png}`

      color_arr = colors.split(" ")

      puts "----------color_arr-----------"
      puts color_arr.inspect

      if color_arr.size == 3
        color_arr.each_with_index do |c, index|
          co = Color.find_by_color_16(c)

          puts "------------color----------------"
          puts co.inspect

          m = dp.dapei_info
          unless co.blank?
            if index == 0
              m.color_one_id = co.id
            elsif index == 1
              m.color_two_id = co.id
            elsif index == 2
              m.color_three_id = co.id
            end
          end
          m.save
        end
      else
        puts "------------------get colors failed------------------"
      end          
     end

   end

end
