def make_docid(url)
  if url.index("tmall.com")
    url = url.gsub(/\?(.*)(id=\d+)(.*)/, '?\2')
  end
  p url
  Digest::MD5.hexdigest( url )
end



namespace :sku do

   task :cron_review  => :environment do
      key = "sku_to_be_shown"
      num = 7

      t = Time.now
      cur_hour = t.hour
      unless [7, 10, 12, 14, 17, 20, 22].include?( cur_hour  )
        num = 0   
      end
     
      unless t.strftime("%w").to_i == 0
        if cur_hour == 22
          num = $redis.llen(key) / 2 
        end

        if cur_hour == 7
          num = $redis.llen(key)
        end
      end

      while num > 0
         num -= 1

         id = $redis.rpop( key )
         sku = Sku.find_by_id( id )
         p key,id

         if sku
           recommend = Recommend.create(:recommended_type => 'Sku', :recommended_id=>sku.id)
         end
      end
   end

   task :rescue_miumiu => :environment do
     brand = Brand.find_by_id(300)
     brand.skus.each do |sku|
       begin
         if not sku
           next
         end
         next if sku.photos.length > 0 
         if sku.deleted or sku.photos.length == 0
           if sku.from == "homepage/mywish" and sku.color_url
             p sku.brand.name
             p sku.buy_url
             if true
                img_url = sku.color_url.gsub("views", "details")
                p img_url
                photo_params={:image_url=>img_url }
                user = User.find_by_id(1)
                @photo = user.build_post(:photo, photo_params)
                @photo.target_id=sku.id
                @photo.target_type="Sku"
                @photo.save!
                sku.deleted = nil
                sku.save
             end
           end
         end
       rescue => e
         p e.to_s
       end
     end
   end

   task :update_docid =>  :environment do
     count = Sku.maximum('id').to_i
     for id in (1..count+1) do
       sku= Sku.find_by_id(count-id+1)
       if sku and sku.buy_url and sku.buy_url.index("tmall.com")
         p sku.buy_url
         sku.docid = make_docid(sku.buy_url)
         sku.save
       end
     end  

   end

   task :fix_sku =>  :environment do
     count = Sku.maximum('id').to_i
     for id in (1..count+1) do
       sku= Sku.find_by_id(count-id+1)
       if sku and sku.deleted and 1.days.since(sku.updated_at) > Time.now 
         p sku.title 
         #p sku.title, sku.url
         sku.deleted = nil
         p sku.deleted
         sku.save
       end
     end

   end




   task :convert_pic => :environment do
     count = Sku.maximum('id').to_i
     for id in (1..count+1) do
       begin
         sku= Sku.find_by_id(count-id+1)
         if not sku
           next
         end
         pnum = 0
         #p sku.brand.name, sku.title
         sku.photos.each do |p|
           file_path = "/var/www/shangjieba/public/uploads/images/#{p.remote_photo_name}"
           if FileTest::exist? file_path
             p sku.brand.name, sku.title, file_path
             pnum += 1
           end
           #if p.url(nil) and p.url(nil) != ""
           #  pnum += 1
           #end
         end
         p "pnum=#{pnum}"
         if sku.deleted or sku.photos.length == 0 or pnum == 0
           if sku.from == "homepage/mywish" and sku.raw_imgs
             p sku.brand.name
             p sku.raw_imgs
             p sku.buy_url
             sku.raw_imgs.split('|').each do |img_url|
                p img_url
                photo_params={:image_url=>img_url }
                user = User.find_by_id(1)
                @photo = user.build_post(:photo, photo_params)
                @photo.target_id=sku.id
                @photo.target_type="Sku"
                @photo.save!
                sku.deleted = nil
                sku.save
             end
           end
         end
       rescue => e
         p e.to_s
       end
     end
   end
end
