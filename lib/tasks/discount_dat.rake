# encoding: utf-8

namespace :discount do
  task :format => :environment do
     count = Discount.maximum('id').to_i
     for id in (1..count) do
         d = Discount.find_by_id(count-id+1)
         break if id > 1000
         if d
            p d 
            p d.title, d.description
            d.format
         end
     end
  end

   
  task :clear => :environment do
     count = Discount.maximum('id').to_i
     for id in (1..count) do
         d = Discount.find_by_id(count-id+1)
         next unless d
         p id
         break if id > 10000
         d.photos.each do |photo|
             ratio = photo.width.to_f / photo.height.to_i
             if photo.width <= 200 or ratio < 0.3
                 print "#{photo.url(:scaled_full)}\t#{photo.width}x#{photo.height}\n"
                 photo.destroy
             end
         end

         if d.photos.length == 0
            d.deleted = true
            d.save
         end
     end
  end 



  task :sync_brand => :environment do
     count = Discount.maximum('id').to_i
     for id in (1..count+1) do
         d = Discount.find_by_id(id)
         print d
         if d and d.discountable_type == "Brand"
            print d
            brand = d.discountable
            if brand
                brand.shops.each do |s|
                  print s
                  s.sync_discount
                end
            end
         end
     end 
  end

  def new_discount(inst, d)
      if not inst
          return
      end
      
      description = d["desc"]
      title = d["title"]
      from  = "weibo"
      docid = "weibo#{d['DOCID']}"
      source = d["Url"]
      publish = d["time"]    

      #don't sync to shops anymore 
      if Discount.find_by_docid(docid)
          #if inst.instance_of?(Brand)
          #  inst.shops.each do |s|
          #    s.sync_discount
          #  end 
          #end
          return
      end
 
      #if not title or title == ""
      #   title = description[0, 16]
      #end
      if title
          title = title[0, 16]
      end

      last_discount =  inst.get_last_discount
      if not d["start_date"]
          d["start_date"] = d["time"].split(" ")[0]
      end
      start_date = Date.parse(d["start_date"])
      end_date  =start_date

      begin
        if d["end_date"] == "" or not d["end_date"]
          end_date = 7.days.since( start_date )
        else
          end_date =  Date.parse(d["end_date"])
        end
      rescue => e
         end_date = 7.days.since( start_date )
      end 
            
      to_be_created = false
      if last_discount
          print "\n", start_date, "==>", last_discount.start_date, "\n"
          print d
          #if inst.instance_of?(Shop) and  start_date > last_discount.start_date
          if inst.instance_of?(Shop) and  start_date > last_discount.start_date
              to_be_created = true
              if start_date < last_discount.end_date
                #if end_date < last_discount.end_date
                #  end_date = last_discount.end_date
                #end
                last_discount.deleted = true
                last_discount.save 
              end
          end
          if inst.instance_of?(Mall) and  start_date > last_discount.start_date
              to_be_created = true
          end
          if inst.instance_of?(Brand)
              to_be_created = true
          end
      else
          to_be_created = true
      end
      if to_be_created
          discount = inst.discounts.new(:title=>title, :description=>description, :publish=>publish,  :from=>from, :docid=>docid, :source => source, :start_date=>start_date, :end_date=>end_date)
          #don't sync to shops any more 
          #if discount.discountable_type == "Brand"
            #inst.shops.each do |s|
            #  s.sync_discount
            #end
          #end

          p inst
          p discount, discount.id, "xxx", title, "\n"
          if discount.save
            d["imgs"].each do |img_url|
              p "!!!!!", discount.id,img_url
              begin
                photo_params={:image_url=>img_url }
                user = User.find_by_id(1)
                @photo = user.build_post(:photo, photo_params)
                @photo.target_id=discount.id
                @photo.target_type="Discount"
                @photo.save!
              rescue=>e
                p e.to_s
              end
            end
          end
          return true
      end
      return false
  end
  

  task :from_weibo => :environment do
     today = DateTime.parse(Time.now.to_s).strftime('%Y%m%d').to_s
     print today
     discount_file  = "/var/www/shangjieba_dat/docs/mall_weibo_#{today}.yml"
     discount_list = YAML::load( File.open( discount_file ) )
     if discount_list
       discount_list.each do |d|
         discount = nil
         print d
         if d['brands'].length == 1
           shop_id = d["shop_id"]
           inst = Shop.find_by_url(shop_id)
           new_discount(inst, d)
         else
           d['shop_ids'].each do |shop_id|
             inst = Shop.find_by_url(shop_id)
             d['title'] = d['desc'][0,16]
             new_discount(inst, d)
           end
           #inst = Mall.find_by_id(d["mall_id"]) 
           #new_discount(inst, d)
         end
         if inst
           #if new_discount(inst, d)
           #  break
           #end
         end
       end
     end
  end

  task :from_brand_weibo => :environment do
     today = DateTime.parse(Time.now.to_s).strftime('%Y%m%d').to_s
     print today
     discount_file  = "/var/www/shangjieba_dat/docs/brand_weibo_news_#{today}.yml"
     discount_list = YAML::load( File.open( discount_file ) )
     if discount_list
       discount_list.each do |d|
         discount = nil
         if d['brand_id']
           brand_id = d["brand_id"]
           inst = Brand.find_by_id(brand_id)
           if new_discount(inst, d)
             print d
             #break
           end
         end
       end
     end
  end
  

  task :from_shhdm => :environment do
     
     today = DateTime.parse(Time.now.to_s).strftime('%Y%m%d').to_s
     print today
     discount_file  = "/var/www/shangjieba_dat/weibo/discount_shhdm_#{today}.yml" 
     
     if FileTest::exist? discount_file
       discount_list = YAML::load_stream( File.open( discount_file ) )
       discount_list.each do |ds|
       ds.each do |d|
         shop_id = d["shop_id"]
         s = Shop.find_by_url(shop_id)
         print "!!!xxx #{shop_id}\n"
         if s
           print s
           title = "#{d['content']}".strip
           description = "#{d['content']}".strip
           if title.length > 16
              tt =  title.split(/[!，,]/)
              print tt
              if tt.length >=1
                 title = tt[0] 
              end
           end
           print "xxx title=", title,  "\n"
           title = title.downcase.gsub(/ +/, "")
           title = title.sub(s.brand.e_name, "")
           title = title.sub(s.brand.c_name, "")
           if title.length > 16
             title = title[0,16]
           end 
           print "!!!title =>", title, "\n content=>", d["content"], "\n"
          
           description = d["content"] 
           last_discount =  s.get_current_discount
           start_date = Date.parse(d["meta"]["start_date"])
           end_date =  Date.parse(d["meta"]["end_date"])
           if last_discount
             print start_date, last_discount.end_date
             if  start_date > last_discount.end_date
               s.discounts.create(:title=>title, :description=>description, :start_date=>start_date, :end_date=>end_date) 
             end
           else
             s.discounts.create(:title=>title, :description=>description, :start_date=>start_date, :end_date=>end_date)
           end
         end
       end
     end
     end
  end

end
