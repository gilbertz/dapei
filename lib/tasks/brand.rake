#encoding: utf-8


def get_domain(url)
   if url
     url.gsub("http://", "").split("/")[0].gsub("www.", "")
   else
     ""
   end
end


namespace :brand do

  task :dapei_count => :environment do
    Brand.where("display_name is not null").find_each(batch_size: 500) do |brand|
      brand.dapei_count = Item.tagged_with(brand.display_name).where('deleted is null and dapei_info_flag is null').size 
      brand.save
      puts brand.id
      puts brand.dapei_count
    end
  end

  task :update_display_name => :environment do
    Brand.find_each do |b|
      if b.display_name.blank?
        b.update_attributes(:display_name=>b.name)
        puts b.id
      end
    end
  end

  task :name => :environment do
     fn =  Rails.root + 'db/seed/brand_name.txt'
     File.new(fn).each do |line|
       cells  = line.strip().split(/[ \t]+/)
       if cells.length >= 2
          brand_id = cells[0]
          display_name = line.gsub(brand_id, "").strip
          brand = Brand.find_by_id(brand_id)
          p brand_id, display_name
          if brand
            brand.display_name = display_name
            brand.save
          end
       end
    end     
  end

  task :spider_status => :environment do
    Brand.all.each do |b|
      next unless b.spiders.length >0 
      spiders = b.spiders
      sku = b.skus.where("skus.category_id < 100").last
      if sku
        last_updated = sku.created_at
      end
      spiders.update_all(:last_updated=>last_updated)
      b.update_attribute(:last_updated , last_updated)
      if sku.nil?
        p "brand id #{b.id}" 
      else
        p sku.docid 
      end
    end
  end  

  
  task :logo => :environment do
     count = Brand.maximum('id').to_i
     for id in (1..count+1) do
         brand = Brand.find_by_id(count-id+1)
         if brand
             fn = "/var/www/shangjieba_dat/uploads/logo/#{brand.id}.png"
             if  File.exists?(fn)
               brand.wide_avatar_url =  AppConfig[:remote_image_domain] + "/uploads/logo/#{brand.id}.png"
               brand.black_avatar_url = AppConfig[:remote_image_domain] + "/uploads/logo_black/#{brand.id}.png"
               brand.white_avatar_url = AppConfig[:remote_image_domain] + "/uploads/logo_white/#{brand.id}.png" 
             else
               brand.wide_avatar_url = "http://www.shangjieba.com/assets/img.jpg"
               brand.black_avatar_url = "http://www.shangjieba.com/assets/img.jpg"
               brand.white_avatar_url = "http://www.shangjieba.com/assets/img.jpg"
             end
             brand.save      
         end
     end
  end

  task :rebrand => :environment do
     brand = Brand.find_by_id( 1071 )
     skus = []
     skus += brand.skus
     brand = Brand.find_by_id( 11 )
     skus += brand.skus

     skus.each do |sku|
       domain =  get_domain(sku.buy_url)
       p domain, sku.buy_url, sku.title
       nbrand = Brand.find_by_domain(domain)
       if not nbrand
         if sku.buy_url.index("giorgioarmani")
           nbrand =  Brand.find_by_id(1104)
         end
       end
       p nbrand
       if nbrand
          sku.brand_id = nbrand.id
          sku.save
       end
     end
  end

  
  task :from_yintai => :environment do
     Brand.where("level = 3").each do |brand|
       c_name = brand.c_name
       e_name = brand.e_name

       p c_name, e_name
       tags = ["13年秋", "13秋", "13冬", "13Q3", "13Q4"]

       yintai = Brand.find_by_id( 1113 )
       yintai.skus.each do |sku|
         title =  sku.title.gsub(" ", "")
         #p sku.title
         if ( c_name and c_name != "" and title.index(c_name) ) or ( e_name and e_name != ""  and title.index(e_name) )
           p c_name, e_name, sku.buy_url, sku.title
           tags.each do |tag|
             if title.index(tag)
               p "match tag=#{tag}"
               sku.brand_id = brand.id
               sku.save
               break
             end
           end
         end
       end
     end
  end  
  

  task :fix_yintai => :environment do
     Brand.where("id = 308").each do |brand|
       c_name = brand.c_name
       e_name = brand.e_name

       p c_name, e_name
       #next if c_name != "" and e_name != ""
       brand.skus.each do |sku|
         title = sku.title
         if sku.buy_url and  sku.buy_url != "" and sku.buy_url.index("yintai")
           p c_name, e_name, sku.buy_url, sku.title
           sku.brand_id = 1113
           sku.save
         end
       end
     end
  end

  task :fix_emely  => :environment do
     target_brand = Brand.find_by_id( 329 )
     c_name = target_brand.c_name.downcase.gsub(' ','')
     e_name = target_brand.e_name.downcase.gsub(' ','')

     p "!!!!", c_name, e_name
     tags = ["2013秋季","2013秋" "13Q3", "13Q4"]
     no_tag = true

     tt = Brand.find_by_id( 387 )
     tt.skus.each do |sku|
       title =  sku.title.downcase.gsub(' ', '')
       p sku.title
       if ( c_name and c_name != "" and title.index(c_name) ) or ( e_name and e_name != "" and title.index(e_name) )
         #p sku.buy_url, sku.title
         tags.each do |tag|
           if no_tag or title.index(tag)
             p sku.title, "match tag=#{tag}"
             sku.brand_id = target_brand.id
             sku.save
             break
           end
         end
       end
     end
  end
 


  task :sku_from_yintai, [:brand_id] => :environment do |t, args|
     puts args[:brand_id]
     bid = args[:brand_id]
     target_brand = Brand.find_by_id( bid ) 
     c_name = target_brand.c_name.downcase.gsub(' ','')
     e_name = target_brand.e_name.downcase.gsub(' ','')
  
     p "!!!!", c_name, e_name
     tags = ["2013秋季","2013秋" "13Q3", "13Q4"] 
     no_tag = true
     
     yintai = Brand.find_by_id( 1113 )
     yintai.skus.each do |sku|
       title =  sku.title.downcase.gsub(' ', '')
       p sku.title
       if ( c_name and c_name != "" and title.index(c_name) ) or ( e_name and e_name != "" and title.index(e_name) )
         #p sku.buy_url, sku.title
         tags.each do |tag| 
           if no_tag or title.index(tag)
             p sku.title, "match tag=#{tag}"
             sku.brand_id = target_brand.id
             sku.save
             break
           end
         end
       end
     end
  end

end
