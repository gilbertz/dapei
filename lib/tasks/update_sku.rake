# encoding: utf-8
require 'thread'
require 'awesome_print'
require 'taobaorb'
require 'xmlsimple'

def traverse_dir(file_path)  
  if File.directory? file_path  
    Dir.foreach(file_path) do |file|  
      if file!="." and file!=".."
        puts "dir=", file, "\n" 
        traverse_dir(file_path+"/"+file){|x| yield x}  
      end  
    end  
  else  
    yield  file_path  
  end  
end  


def make_docid(url)
  case url
  when /tmall.com|tmall.hk/
    url = url.gsub(/\?(.*)(id=\d+)(.*)/, '?\2')
  when /net-a-porter.com/
    url_arr = url.split("/")
    if url_arr.size == 7
      str_to_replace = url_arr.last(2).join("\/")
      str_to_sub = "\/#{str_to_replace}"
      url = url.gsub( /#{Regexp.escape(str_to_sub)}/, "")
    end
  when /swarovski.com.cn/
    url = url.split(";").first
  when /jumei.com/
    url = url.split("?").first
  when /yintai.com/
    url = url.split("?").first
    url = "#{url}?source=shangjie"
  end
  Digest::MD5.hexdigest( url )
end

def make_url(url, pno)
  case url
  when /yintai.com/
    url = "http://m.yintai.com/Sales/ProductDetail?itemCode=#{pno}&source=shangjie"
  else
  end
  url
end

def make_doc(doc)
    ndoc = {}
    ndoc[:docid] = make_docid( doc["url"] )
    ndoc[:from]  = "homepage"
    ndoc[:title] = doc["title"]
    if ndoc[:title] == ""
      ndoc[:title] = "新品"
    end

    doc_price = doc["price"] || "" #.match(/[\d\.,]+/).to_s if doc["price"]
    if doc_price =~ /美元/
      doc_price = doc_price.gsub(/美元/, "$")
    end
    if doc_price =~ /美西价：/
      doc_price = doc_price.gsub(/美西价：/, "")
    end
    ndoc[:price] = doc_price
    doc_origin_price = doc["origin_price"] || ""
    if doc_origin_price =~ /美西价：/
      doc_origin_price = doc_origin_price.gsub(/美西价：/, "")
    end
    ndoc[:origin_price] = doc_origin_price.strip.empty? ? doc_price : doc_origin_price
    ndoc[:desc]  = doc["desc"]
    ndoc[:brand_id] = doc["brand_id"]
    if brand = Brand.find(doc["brand_id"])
      ndoc[:level] = brand.level
    end     
    ndoc[:sold_count] = doc["sold_count"] unless doc["sold_count"].nil? || doc["sold_count"].strip.empty?
    ndoc[:comments_count] = doc["hot"] unless doc["hot"].nil? || doc["hot"].strip.empty?
    ndoc[:rate_score] = doc["rate"] unless doc["rate"].nil? || doc["rate"].strip.empty?
    unless doc["store_count"].nil? || doc["store_count"].strip.empty?
      store_count_val = doc["store_count"].match(/\d+/).to_s
      ndoc[:store_count] = store_count_val
    end

    if ndoc[:brand_id] == "18"
      if ndoc[:title].downcase.index("shoebox")
         ndoc[:brand] = "shoebox"
         ndoc[:brand_id] = "1035"
      end
    end
    ndoc[:publish] = doc["time"]
    url = doc["url"]
    pno = doc["pno"] || ""
    buy_url = make_url(url, pno)
    ndoc[:buy_url] = buy_url
    ndoc[:spider_id] = doc["spider_id"] if doc["spider_id"]
    ndoc[:origin_platform] = doc["origin_platform"] if doc["origin_platform"]
    ndoc[:pno] = pno

    (1..4).each do |i|
      if doc["desc#{i}"] and doc["desc#{i}"] != ""
        ndoc[:desc] += doc["desc#{i}"]
      end
    end

    ndoc[:category_id] = 3
    ndoc[:category_id] = doc["category_id"] if doc["category_id"]
    ndoc[:sub_category_id] = doc["sub_cat_id"] if doc["sub_cat_id"] && doc["sub_cat_id"].to_i > 0
   
    ndoc[:imgs] = []
    ndoc[:dp_imgs] = []

    if doc["is_agent"]
      ndoc[:is_agent] = doc["is_agent"]
    end

    if doc["is_guide"]
      ndoc[:is_guide] = doc["is_guide"]
    end

    if doc["freight"] && !doc["freight"].strip.empty? 
      ndoc[:freight] = doc["freight"]
    end

    if doc["sizes"] && !doc["sizes"].strip.empty? 
      ndoc[:sizes] = doc["sizes"]
    end

    if doc["colors"] && !doc["colors"].strip.empty? 
      ndoc[:color] = doc["colors"]
    end

    if doc["dp_imgs"] and doc["dp_imgs"] != ""
      ndoc[:dp_imgs]  = doc["dp_imgs"]
    end
    if doc["simg"] and doc["simg"] != ""
      doc["imgs"] += doc["simg"]
    end
    if doc["imgs"]
      doc["imgs"] = doc["imgs"].uniq
      doc["imgs"].each do |img|
        if img =~ /gif$/ or img == "" or img == nil
          next
        end

        ndoc[:imgs] << img
      end
    end
    ndoc
end


def process_activity(doc)
    p doc

    description = doc[:desc]
    docid = doc[:docid]
    source = "#"
    publish = doc[:publish]
    from = "weibo"

    inst  = Brand.find_by_id(doc[:brand_id])
    return if not inst
    
    title = "新品资讯"
    tag = description.gsub(/(.*)#(.*?)#(.*)/, '\2')
    title = tag if tag and tag != ""
 
    if Discount.find_by_docid(docid)
       return
    end

    start_date = Date.parse( doc[:publish].split(" ")[0] )
    end_date = 7.days.since( start_date )

    ld = inst.discounts.last

    discount = inst.discounts.new(:title=>title, :description=>description, :publish=>publish,  :from=>from, :docid=>docid, :source => source, :start_date=>start_date, :end_date=>end_date)
    if discount.save
        doc[:imgs].each do |img_url|
            p "!!!!!", discount.id,img_url
            begin
                Photo.attach(img_url, discount)
            rescue=>e
                p e.to_s
            end
        end
    end

    inst.shops.each do |s|
       s.sync_discount
    end
 
end

def process_images(doc)
  puts doc[:docid]
  sku = Sku.find_by_docid(doc[:docid])
  if sku
      p doc[:imgs]

      if sku.photos.nil? || sku.photos.empty?
        doc[:imgs].each do |img_url|
          img_url = img_url.gsub(' ', '')
          begin
            Photo.attach(img_url, sku)
          rescue=>e
            p e.to_s
          end
        end
      end
      return unless doc[:dp_imgs]      

      if doc[:dp_imgs].length > 0 
        p "add dp imgs=", doc[:dp_imgs]
        doc[:dp_imgs].each do |img_url|
          begin
            Photo.attach(img_url, sku)
          rescue=>e
            p e.to_s
          end 
        end
      end

  end
end

def process_tshow(doc)
  p doc[:docid]
  doc_imgs = doc[:imgs]
  tshow = Tshow.find_by_docid(doc[:docid])
  if tshow
    tshow.update_attributes(doc.except(:imgs, :time))
    if tshow.photos.nil? || tshow.photos.empty?
        doc_imgs.each do |img_url|
          p "reupload image" + img_url
          img_url = img_url.strip
          begin
            `wget #{img_url}`
            unless $?==0
              img_url = img_url.gsub("fullscreen.jpg", "f.jpg")
            end
          rescue=>e
            p e.to_s
          end

          begin
            Photo.attach(img_url, tshow)
          rescue=>e
            p e.to_s
          end
        end
    end
   
    return
  end

  tshow = Tshow.new(doc.except(:imgs, :time))
  if tshow.save!
      doc_imgs.uniq.each do |img_url|
         begin
           Photo.attach(img_url, tshow)
         rescue=>e
           p e.to_s
         end
      end
  end

end

def process(doc, update=false)
  p doc[:docid]
  return if doc.empty? || doc[:imgs].length == 0
  
  return if doc[:from] == "weixin"

  return if Discount.find_by_docid(doc[:docid])
  sku = Sku.find_by_docid(doc[:docid]) 

  if sku #|| ( doc[:pno] and doc[:pno] != "" and Sku.find_by_pno(doc[:pno]) )
      puts "exists sku for docid=", doc[:docid], " updating... \n" 
      
      return if doc[:from] == "weibo"
  
        begin
          sku.update_attributes(doc)
          sku.format_price
        rescue=>e
        end
      
      
      p doc[:imgs]

      if sku.photos.nil? || sku.photos.empty?
        doc[:imgs].each do |img_url|
          p "reupload image" + img_url
          img_url = img_url.gsub(' ', '')
          begin
            Photo.attach(img_url, sku)
          rescue=>e
            p e.to_s
          end
        end
      end

      photos_size = sku.photos.length
      imgs_size = doc[:imgs].length

      if photos_size < imgs_size
        doc[:imgs].each do |img_url|
          p "completement image" + img_url
          img_url = img_url.gsub(' ', '')
          next if img_url.split("/").size <= 3
          begin
            Photo.attach(img_url, sku)
          rescue=>e
            p e.to_s
          end
        end
       
      end

      if sku.photos.length == 0
        sku.deleted = true
        sku.save
      else
        sku.deleted = nil
        sku.save 
      end

      return unless doc[:dp_imgs]      

      if doc[:dp_imgs].length > 0 
        p "add dp imgs=", doc[:dp_imgs]
        doc[:dp_imgs].each do |img_url|
          next if img_url.split("/").size <= 3
          begin
            Photo.attach(img_url, sku)
          rescue=>e
            p e.to_s
          end 
        end
      end
      new_icon_urls = process_colors(doc[:color])
      update_sku_colors(sku, doc[:color], new_icon_urls) if new_icon_urls && !new_icon_urls.empty?

      return
      
  end

  if doc[:from] == "weibo" 
    brand = Brand.find( doc[:brand_id] ) 
    p "sku doc from weibo", brand.level
    if brand.level != 4
       process_activity( doc )
       return
    end 
  end 

  return if doc[:type] == "Discount"
  cat = Category.find(doc[:category_id])
  cat_min_price = cat.min_price || 0
  cat_max_price = cat.max_price || 0
  doc_price = doc[:price].match(/[\d\.,]+/).to_s
    case doc[:buy_url]
    when /zalando.de/
      doc_price = doc_price.gsub(/(.*)([,，])(.*)/, '\1.\3')
    else
    end
puts doc[:price]

    doc_currency_sign = Sku.parse_currency_sign(doc[:price])
    currency_rate_num = Sku.get_currency_rate_val(doc_currency_sign, doc[:buy_url])
  doc_price = doc_price.gsub(",","").to_f
  doc_price = doc_price*currency_rate_num

puts doc_price.to_s

  if cat_max_price > 0 && cat_min_price > 0
    b_conditional = !(cat_max_price >= doc_price && cat_min_price <= doc_price)
  elsif cat_max_price > 0 && cat_min_price == 0 
    b_conditional = !(cat_max_price >= doc_price)
  elsif cat_max_price == 0 && cat_min_price > 0 
    b_conditional = !(cat_min_price <= doc_price)
  elsif cat_max_price == 0 && cat_min_price == 0
    b_conditional = false
  else
    b_conditional = true
  end

  return if b_conditional

    sku = Sku.new( doc.merge(:s_price => doc[:price]) )
    if sku.save!
      sku.format_price
      sku_show_price = sku.get_show_price || "" 
      sku_refer_price = sku_show_price.gsub("¥","").to_f.round
      sku.update_attribute(:refer_price, sku_refer_price)
      doc[:dp_imgs].uniq.each do |img_url|
         begin
           Photo.attach(img_url, sku, true)
         rescue=>e
           p e.to_s
         end
      end

      doc[:imgs].uniq.each do |img_url|
         begin
           Photo.attach(img_url, sku)
         rescue=>e
           p e.to_s
         end
      end

      new_icon_urls = process_colors(doc[:color])
      update_sku_colors(sku, doc[:color], new_icon_urls) if new_icon_urls && !new_icon_urls.empty?
    end
  
end

def update_sku_colors(sku, doc_color, icon_urls)
  old_doc_color = JSON.parse(doc_color)
  old_doc_color["icon_urls"] = icon_urls
  new_doc_color = old_doc_color.to_json
  sku.update_attribute(:color, new_doc_color)
end

def process_colors(doc_color)
  unless doc_color.nil? || doc_color.strip.empty?
    new_icon_url_arr = []
    JSON.parse(doc_color).symbolize_keys[:icon_urls].each do |icon_url|
      next if icon_url.nil?
      photo_id = Digest::MD5.hexdigest(icon_url)
      photo = Photo.find_by_digest(photo_id)
      new_icon_url = ""
      new_icon_url = photo.url(:thumb_color) unless photo.nil?
      new_icon_url_arr << new_icon_url if !new_icon_url.strip.empty?
    end
    new_icon_url_arr
  end
end

def template_import
   @spiders.each do |spider|
     next if spider.stop
     brand_id = spider.brand_id
     spider_id = spider.id
     next if brand_id.nil? 
     cats = Category.where{(id >= 3)&(id < 15)}
     
     cats.each do |c|
       cat_id = c.id
       pkey = "brand_#{brand_id}_spider_#{spider_id}_product_pages_#{cat_id}"
       lks = @redis.lrange(pkey, 0, -1)
       brand_cat_list_length = lks.length
       next if brand_cat_list_length == 0

       for i in (1..brand_cat_list_length) do 
         link = @redis.rpop(pkey)
         begin
           p link
           next if link.nil?
             if cat_id==9 || cat_id==10
               link_sub_cat_id = link.split(",")
               if link_sub_cat_id.length == 2
                 link = link_sub_cat_id.last
               else
                 link = link_sub_cat_id.first
               end
             end
           link_docid = make_docid(link)
           doc_yml = @redis.get link_docid
           next if doc_yml.nil?
           doc = YAML::load( doc_yml )
           process( make_doc(doc) )
           @redis.del link_docid
         rescue => e
           p e.to_s
         end
       end

       #@redis.del(pkey)
     end
   end

end

def delete_non_current_spider_skus
  @current_brand.skus.where{created_at>DateTime.new(2014,1,1,0,0,0)}.each do |sku|
    puts "all docid #{sku.docid}"
    if sku.buy_url && !sku.buy_url =~ @reg_match
      sku.update_attribute(:deleted, true)
      puts "updated docid #{sku.docid}"
      matter = Matter.where{sku_id==sku.id}.first
      if matter
        sku.update_attribute(:deleted, nil)
      end
    end
  end
end

namespace :dat do
  @redis =  Redis.new(:host => '114.80.100.12', :port => 6379)

  task :update_amazon_photos => :environment do
    spider_ids = Spider.where{template_id==1284}.map(&:id)
    skus = Sku.where{spider_id>>spider_ids}
    skus.each do |sku|
    begin
    html_source = RestClient.get sku.buy_url  
    str_img_urls = html_source.split("'colorImages': { 'initial':").last.split("'colorToAsin': {'initial': {}}").first.strip[0..-3].split("\",\"thumb\"")
    puts str_img_urls
     str_img_urls.each do |img_url|
     real_img_url = img_url.split("\"hiRes\":\"").last
     img_urls = []
     if real_img_url.include?("1500")
      img_urls << real_img_url
     end
     ap img_urls

        img_urls.each do |img_url|
          p "reupload image" + img_url
          img_url = img_url.gsub(' ', '')
          begin
            Photo.attach(img_url, sku)
          rescue=>e
            p e.to_s
          end
        end
     end
    rescue=>e
      puts e.to_s
      error_message = e.to_s
      if error_message =~ /404 Resource Not Found/
        redis = Redis.new(:host => '114.80.100.12', :port => 6379)
        doc = {}
        doc["docid"]=sku.docid
        key = "sku_deleted_#{sku.docid}"
        redis.set(key, doc.to_yaml)
      end
      next
    end
    end
  end

  task :switch_brand_origin_source => :environment do
    Brand.all.each do |brand|
      next if brand.current_spider.nil?
      current_spider_template = brand.current_spider.template_id 
      @current_brand = brand
      case current_spider_template
      when 89
        @reg_match = /tmall.com|tmall.hk/
      when 111
        @reg_match = /net-a-porter.com/
      else
      end
      next if @reg_match.nil?
      delete_non_current_spider_skus
    end
  end

  task :process_docid_images => :environment do
    processed_len = @redis.lrange("images_need_to_be_processed",0,-1).count
    puts processed_len
    for i in (1..processed_len) do
      begin
        doc_yml = @redis.lpop("images_need_to_be_processed")
        doc = YAML::load(doc_yml)
        puts doc[:docid]
        process_images(doc)
      rescue => e
        p e.to_s
      end 
    end
  end

  task :reupload_photos => :environment do
    skus = Sku.where{created_at>DateTime.new(2014,4,9,20,14,30)}.order{created_at.asc}
    skus.each do |sku|
      p sku.buy_url
      begin
        doc_yml = @redis.get sku.docid
        doc = YAML::load( doc_yml )
        process( make_doc(doc) )
      rescue => e
        p e.to_s
      end
    end
  end

  task :import_tshow, [:brand_id] => :environment do |t, args|
    @redis = Redis.new(:host => '114.80.100.12', :port => 6379)
    t = Thread.new do 
     brand_id = args[:brand_id]
         pkey = "brand_#{brand_id}_tshow_pages"
         lks = @redis.lrange(pkey, 0, -1)
         brand_list_length = lks.length
       if brand_list_length > 0

         for i in (1..brand_list_length) do 
           link = @redis.rpop(pkey)
           begin
             p link
             next if link.nil?
             link_docid = Digest::MD5.hexdigest(link)
             doc_yml = @redis.get link_docid
             next if doc_yml.nil?
             doc = YAML::load(doc_yml).symbolize_keys
             process_tshow(doc.merge(:docid=>link_docid))
             @redis.del link_docid
           rescue => e
          #   p e.to_s
           end
         end
       end
         #@redis.del(pkey)
    end
    t.join
  end

  task :import_sku, [:brand_id] => :environment do |t, args|
    t = Thread.new do 
     brand_id = args[:brand_id]
     spiders = Brand.find(brand_id).spiders
     spiders.each do |spider|
      spider_id = spider.id
      cats = Category.where("id >= 3").where("id < 15")
       cats.each do |c|
         cat_id = c.id
         pkey = "brand_#{brand_id}_spider_#{spider_id}_product_pages_#{cat_id}"
         lks = @redis.lrange(pkey, 0, -1)
         brand_cat_list_length = lks.length
         next if brand_cat_list_length == 0

         for i in (1..brand_cat_list_length) do 
           link = @redis.rpop(pkey)
           begin
             p link
             next if link.nil?
             if cat_id==9 || cat_id==10
               link_sub_cat_id = link.split(",")
               if link_sub_cat_id.length == 2
                 link = link_sub_cat_id.last
               else
                 link = link_sub_cat_id.first
               end
             end
             link_docid = make_docid(link)
             doc_yml = @redis.get link_docid
             next if doc_yml.nil?
             doc = YAML::load( doc_yml )
             process( make_doc(doc) )
             @redis.del link_docid
           rescue => e
          #   p e.to_s
           end
         end

         #@redis.del(pkey)
       end
      end
    end
    t.join
  end

  task :update_pno, [:brand_id] => :environment do |t, args|
     brand_id_val = args[:brand_id]
     puts "brand id #{brand_id_val}"
     skus = Sku.where{brand_id==brand_id_val}
     puts skus.count
     skus.each do |sku|
       sku_url = sku.buy_url
       puts sku.docid
       puts sku_url
       unless sku_url.nil? || sku_url.empty?
         next unless sku_url.include?("id=")
         id_str = sku_url.split("id=").last
         id_str = id_str.split("&").first if id_str.include?("&") 
         puts id_str
         sku.update_attribute(:pno, id_str)
       end
     end
  end

  task :update_tmall_pno => :environment do 
     skus = Sku.where{(buy_url=~"%tmall.com%")|(buy_url=~"%tmall.hk%")}.order{created_at.desc}.limit(10000)
     skus.each do |sku|
       sku_url = sku.buy_url
       puts sku_url
       next unless sku_url =~ /tmall.com|tmall.hk/
       puts sku.docid
       unless sku_url.nil? || sku_url.empty?
         next unless sku_url.include?("id=")
         id_str = sku_url.split("id=").last
         id_str = id_str.split("&").first if id_str.include?("&") 
         puts id_str
         sku.update_attribute(:pno, id_str)
       end
     end
  end

  task :create_tmall_promotions => :environment do 
     skus = Sku.where{(buy_url=~"%tmall.com%")|(buy_url=~"%tmall.hk%")}.order{created_at.desc}.limit(10000)
     skus.each do |sku|
       sku_pno = sku.pno
       next if sku_pno.nil? || sku_pno.strip.empty?
       puts sku.docid
       puts sku_pno
       arr_item_promotions = Taobao::Promotion.new(sku_pno).processed_promotion_in_item
       ap arr_item_promotions
       unless arr_item_promotions.nil?
         arr_item_promotions.each do |item_promotion|
           sku_promotion = SkuPromotion.where{(item_id==item_promotion[:item_id])&(promotion_id==item_promotion[:promotion_id])}.first
           sku.sku_promotions.create(item_promotion) unless sku_promotion
         end
       end
     end
  end

  task :update_tmall_discount => :environment do 
     skus = Sku.where{(buy_url=~"%tmall.com%")|(buy_url=~"%tmall.hk%")}.order{created_at.desc}
     skus.each do |sku|
       sku_url = sku.buy_url
       next unless sku_url =~ /tmall.com|tmall.hk/
       unless sku_url.nil? || sku_url.empty?
         sku_price = sku.price.to_f
         sku_origin_price = sku.origin_price.to_f
         if sku_price == sku_origin_price
           has_discount_val = false
           off_percent_val = 100
         else
           has_discount_val = true
           off_price = sku_origin_price >= sku_price ? sku_origin_price - sku_price : 0
           puts sku.docid if sku_origin_price < sku_price
           off_percent_val = ((off_price/sku_origin_price).round(2))*100
           if sku.deleted == true
             off_percent_val = 0
           end
         end
         
         discount_hash = {:has_discount=>has_discount_val, :off_percent=>off_percent_val}

         sku.update_attributes(discount_hash)
       end
     end
  end

  task :import_authweb_sku => :environment do 
   @spiders = Spider.where{(brand_id > 1)&-(template_id>>[89, 111, 65])&(stop==false)}.order{last_updated.desc}
   template_import
  end

  task :import_tmall_sku => :environment do 
   @spiders = Spider.where{(brand_id > 1)&(template_id==89)&(stop==false)}.order{last_updated.desc}
   template_import
  end

  task :import_porter_sku => :environment do 
   @spiders = Spider.where{(brand_id > 1)&(template_id==111)&(stop==false)}.order{last_updated.desc}
   template_import
  end

  task :import_zalando_sku => :environment do 
   @spiders = Spider.where{(brand_id > 1)&(template_id==893)&(stop==false)}.order{last_updated.desc}
   template_import
  end

  task :import_elleshop_sku => :environment do 
   @spiders = Spider.where{(brand_id > 1)&(template_id==685)&(stop==false)}.order{last_updated.desc}
   template_import
  end

  task :import_shangpin_sku => :environment do 
   @spiders = Spider.where{(brand_id > 1)&(template_id==944)&(stop==false)}.order{last_updated.desc}
   template_import
  end

  task :import_theoutnet_sku => :environment do 
   @spiders = Spider.where{(brand_id > 1)&(template_id==1105)&(stop==false)}.order{last_updated.desc}
   template_import
  end

  task :import_secoo_sku => :environment do 
   @spiders = Spider.where{(brand_id > 1)&(template_id==1153)&(stop==false)}.order{last_updated.desc}
   template_import
  end

  task :import_shopbop_sku => :environment do 
   @spiders = Spider.where{(brand_id > 1)&(template_id==16)&(stop==false)}.order{last_updated.desc}
   template_import
  end

  task :import_yintai_sku => :environment do 
   @spiders = Spider.where{(brand_id > 1)&(template_id==65)&(stop==false)}.order{last_updated.desc}
   template_import
  end

  task :check_now_price_updated_sku => :environment do
    @redis = Redis.new(:host => '114.80.100.12', :port => 6379)
    now_price_updated_sku_keys = @redis.keys("sku_now_price_updated*")
    p "check now price updated sku begin"
    now_price_updated_sku_keys.each do |now_price_updated_sku_key|
      now_price_updated_sku_yml = @redis.get(now_price_updated_sku_key)
      now_price_updated_sku = YAML::load(now_price_updated_sku_yml)
      next unless now_price_updated_sku[:docid]
      sku = Sku.find_by_docid(now_price_updated_sku[:docid])
      next if sku.nil?
      p sku.buy_url
      sku.update_attribute(:price, now_price_updated_sku[:now_price])
      sku.format_price
    end
    @redis.del(*now_price_updated_sku_keys)
    p "check now price updated skus end"
  end

  task :check_price_updated_sku => :environment do
    @redis = Redis.new(:host => '114.80.100.12', :port => 6379)
    price_updated_sku_keys = @redis.keys("sku_price_updated*")
    p "check price updated sku begin"
    price_updated_sku_keys.each do |price_updated_sku_key|
      price_updated_sku_yml = @redis.get(price_updated_sku_key)
      price_updated_sku = YAML::load(price_updated_sku_yml)
      next unless price_updated_sku[:docid]
      sku = Sku.find_by_docid(price_updated_sku[:docid])
      next if sku.nil?
      p sku.buy_url
      sku.update_attribute(:price, price_updated_sku[:price])
      sku.format_price
    end
    @redis.del(*price_updated_sku_keys)
    p "check price updated skus end"
  end
  
  task :check_sizes_color_updated_sku => :environment do
    @redis = Redis.new(:host => '114.80.100.12', :port => 6379)
    sizes_color_updated_sku_keys = @redis.keys("sku_sizes_color_updated*")
    p "check sizes color updated sku begin"
    sizes_color_updated_sku_keys.each do |sizes_color_updated_sku_key|
      sizes_color_updated_sku_yml = @redis.get(sizes_color_updated_sku_key)
      sizes_color_updated_sku = YAML::load(sizes_color_updated_sku_yml)
      next unless sizes_color_updated_sku[:docid]
      sku = Sku.find_by_docid(sizes_color_updated_sku[:docid])
      next if sku.nil?
      p sku.buy_url
      p sizes_color_updated_sku[:colors]
      colors_updated = sizes_color_updated_sku[:colors]
      if colors_updated
        new_icon_urls = process_colors(colors_updated)
        hash_colors_updated = JSON.parse(colors_updated)
        color_names_arr = hash_colors_updated["color_names"].compact.reject{|ele| ele.strip.empty?}
        update_sku_colors(sku, colors_updated, new_icon_urls) if color_names_arr && !color_names_arr.empty?#if new_icon_urls && !new_icon_urls.empty?
      end
      sizes_updated = sizes_color_updated_sku[:sizes]
      sku.update_attribute(:sizes, sizes_updated) if sizes_updated && !sizes_updated.strip.empty?
    end
    @redis.del(*sizes_color_updated_sku_keys)
    p "check sizes color updated skus end"
  end

  task :check_soldout_sku => :environment do
    @redis = Redis.new(:host => '114.80.100.12', :port => 6379)
    soldout_sku_keys = @redis.keys("sku_deleted*")
    p "check_soldout_sku begin"
    soldout_sku_keys.each do |soldout_sku_key|
      soldout_sku_yml = @redis.get(soldout_sku_key)
      soldout_sku = YAML::load(soldout_sku_yml)
      next unless soldout_sku["docid"]
      sku = Sku.find_by_docid(soldout_sku["docid"])
      next if sku.nil?
      p sku.buy_url
      sku.update_attribute(:deleted, true)
    end
    @redis.del(*soldout_sku_keys)
    p "check soldout skus end"
  end

  task :get_realtime_currency_rate => :environment do
    @redis = Redis.new(:host => '114.80.100.12', :port => 6379)
    currency_rate_url = "http://query.yahooapis.com/v1/public/yql?q=select%20%2a%20from%20yahoo.finance.xchange%20where%20pair%20in%20%28%22EURCNY%22,%20%22JPYCNY%22,%20%22GBPCNY%22,%20%22AUDCNY%22,%20%22CHFCNY%22,%20%22CADCNY%22,%20%22USDCNY%22,%20%22HKDCNY%22,%20%22SGDCNY%22%29&env=store://datatables.org/alltableswithkeys"
    xml_data = RestClient.get currency_rate_url
    data = XmlSimple.xml_in(xml_data)
    @redis.del "current_currency_rates"
    data.symbolize_keys[:results][0]["rate"].each do |rate|
      rate = rate.symbolize_keys
      rate_id = rate[:id]
      currency_name = rate_id[0..2]
      currency_rate = rate[:Rate][0].to_f
      currency_data = {:name=>currency_name, :rate=>currency_rate}.to_json

      @redis.rpush("current_currency_rates", currency_data)
    end
  end
 
  task :update_currency_rate => :environment do
    @redis = Redis.new(:host => '114.80.100.12', :port => 6379)
    current_currency_rates = @redis.lrange("current_currency_rates", 0, -1)
    current_currency_rates.each do |currency_rate|
      currency_name_rate = JSON.parse(currency_rate).symbolize_keys
      name = currency_name_rate[:name]
      rate = currency_name_rate[:rate]
      currencyrate = CurrencyRate.find_by_name(name)
      currencyrate.update_attribute(:rate, rate)
    end
  end
  task :update_sku_refer_price => :environment do
    all_skus = Sku.order{created_at.desc}.first(10000)
    all_skus.each do |sku|
      puts sku.docid
      sku.update_attribute(:deleted, true) if sku.docid.nil?
      sku_show_price = sku.get_show_price || ""
      sku_refer_price = sku_show_price.gsub("¥","").to_f.round
      sku.update_attribute(:refer_price, sku_refer_price)
    end
  end

  task :import_all_sku => :environment do
     spiders = Spider.where(:stop => false ).order("updated_at desc")
     spiders.each do |spider|
       brand_id = spider.brand_id
       spider_id = spider.id
       next if brand_id.nil?
       cats = Category.where("id >= 3").where("id < 15")
       
       cats.each do |c|
         cat_id = c.id
         pkey = "brand_#{brand_id}_spider_#{spider_id}_product_pages_#{cat_id}"
         lks = @redis.lrange(pkey, 0, -1)
         brand_cat_list_length = lks.length
         next if brand_cat_list_length == 0

         for i in (1..brand_cat_list_length) do 
           link = @redis.rpop(pkey)
           begin
             p link
             next if link.nil?
             if cat_id==9 || cat_id==10
               link_sub_cat_id = link.split(",")
               if link_sub_cat_id.length == 2
                 link = link_sub_cat_id.last
               else
                 link = link_sub_cat_id.first
               end
             end
             link_docid = make_docid(link)
             doc_yml = @redis.get link_docid
             next if doc_yml.nil?
             doc = YAML::load( doc_yml )
             process( make_doc(doc) )
             @redis.del link_docid
           rescue => e
             p e.to_s
           end
         end
         #@redis.del(pkey)
       end
     end
  end


  task :clear_tmall_sku => :environment do |t, args|
      count = Sku.maximum('id').to_i
      for id in (1..count+1) do
         sku = Sku.find_by_id(count-id+1)
         next if not sku
         if not sku.deleted and sku.category_id < 100 and 15.days.since(sku.created_at) > Time.now
           next unless sku.buy_url =~ /tmall/
           if /11-11/ =~ sku.title or /11月11日/ =~ sku.title or /11特价/ =~ sku.title or /11狂欢价/ =~ sku.title
             p sku.buy_url
             p sku.title
             sku.remove
           end
         end
      end
  end
  task :create_user_behaviours  => :environment do
  puts "in create user behaviours"
  current_path = Dir.pwd
  puts current_path
File.open("log/parsed_production.txt", "r") do |f|
  f.each_line do |line|
    puts line
    user_behavior_record = line.gsub(" ", ";").split(";")
    if user_behavior_record.length == 10
      user_token = "null"
      request_url_token = user_behavior_record[1].split("&")
      request_url_token.each do |url_param|
        if url_param.include?("token=")
          user_token = url_param.split("=").last
        end
      end
      user_token = "null" if user_token.strip.empty?
      user = User.find_by_authentication_token(user_token)
      user_id = user.id unless user.nil?
      user_request_time = [user_behavior_record[7], user_behavior_record[8]].join(" ")
      user_behaviour = {:user_id=>user_id, 
                        :request_url=>user_behavior_record[1], 
                        :token=>user_token, 
                        :ip_address=>user_behavior_record[0], 
                        :request_time=>user_request_time, 
                        :request_method=>user_behavior_record[5], 
                        :request_controller=>user_behavior_record[2], 
                        :request_action=>user_behavior_record[3], 
                        :request_format=>user_behavior_record[4], 
                        :request_status=>user_behavior_record[6] }
     begin
      ubehaviour = UserBehaviour.where{(ip_address==user_behavior_record[0])&(token==user_token)&(request_url=~user_behavior_record[1])}.first
      UserBehaviour.create(user_behaviour) if ubehaviour.nil?
     rescue=>e
       puts e.to_s
     end
    end
  end
end

  end
  task :create_user_behaviours_xmlpipe  => :environment do

yesterday_str = Date.yesterday.strftime("%Y%m%d")

     xml_file = File.open("log/parsed_production#{yesterday_str}.xml", "w+") 
     xml_file.write("<?xml version=\"1.0\" encoding=\"utf-8\"?>\n")
     xml_file.write("<sphinx:docset>\n\n")
     xml_file.write("<sphinx:schema>\n")
     xml_file.write("<sphinx:field name=\"request_url\"/>\n")
     xml_file.write("<sphinx:field name=\"token\"/>\n")
     xml_file.write("<sphinx:field name=\"ip_address\"/>\n")
     xml_file.write("<sphinx:field name=\"request_controller\"/>\n")
     xml_file.write("<sphinx:field name=\"request_action\"/>\n")
     xml_file.write("<sphinx:field name=\"request_method\"/>\n")
     xml_file.write("<sphinx:field name=\"request_format\"/>\n")
     xml_file.write("<sphinx:field name=\"request_status\"/>\n")
     xml_file.write("<sphinx:attr name=\"request_url\"/>\n")
     xml_file.write("<sphinx:attr name=\"token\"/>\n")
     xml_file.write("<sphinx:attr name=\"ip_address\"/>\n")
     xml_file.write("<sphinx:attr name=\"request_controller\"/>\n")
     xml_file.write("<sphinx:attr name=\"request_action\"/>\n")
     xml_file.write("<sphinx:attr name=\"request_method\"/>\n")
     xml_file.write("<sphinx:attr name=\"request_format\"/>\n")
     xml_file.write("<sphinx:attr name=\"request_status\"/>\n")
     xml_file.write("<sphinx:attr name=\"request_time\" type=\"string\"/>\n")
     xml_file.write("<sphinx:attr name=\"user_id\" type=\"int\" bits=\"16\" default=\"0\"/>\n")
     xml_file.write("</sphinx:schema>\n\n")

File.open("log/parsed_production#{yesterday_str}.txt", "r") do |f|
     document_id=1
  f.each_line do |line|
    puts line
    user_behavior_record = line.gsub(" ", ";").split(";")
    if user_behavior_record.length == 10
      user_token = "null"
      request_url_token = user_behavior_record[1].split("&")
      request_url_token.each do |url_param|
        if url_param.include?("token=")
          user_token = url_param.split("=").last
        end
      end
      user_token = "null" if user_token.strip.empty?
      user = User.find_by_authentication_token(user_token)
      user_id = user.id unless user.nil?
      user_request_time = [user_behavior_record[7], user_behavior_record[8]].join(" ")

      request_url = user_behavior_record[1]
      request_url = request_url.gsub('&', '&amp;')
      ip_address = user_behavior_record[0]
      request_controller = user_behavior_record[2]
      request_action = user_behavior_record[3]
      request_method = user_behavior_record[5]
      request_format = user_behavior_record[4]
      request_status = user_behavior_record[6]
      
      xml_file.write("<sphinx:document id=\"#{document_id}\">\n")
      xml_file.write("<request_url>#{request_url}</request_url>\n")
      xml_file.write("<token>#{user_token}</token>\n")
      xml_file.write("<ip_address>#{ip_address}</ip_address>\n")
      xml_file.write("<request_controller>#{request_controller}</request_controller>\n")
      xml_file.write("<request_action>#{request_action}</request_action>\n")
      xml_file.write("<request_method>#{request_method}</request_method>\n")
      xml_file.write("<request_format>#{request_format}</request_format>\n")
      xml_file.write("<request_status>#{request_status}</request_status>\n")
      xml_file.write("<request_time>#{user_request_time}</request_time>\n")
      xml_file.write("<user_id>#{user_id}</user_id>\n")
      xml_file.write("</sphinx:document>\n\n")
                        
    end
     document_id += 1
  end
  
end

     xml_file.write("</sphinx:docset>\n")
  end
  task :create_shangjieba_actions  => :environment do

File.open("/var/www/shangjieba/log/routes.txt", "r") do |f|

  f.each_line do |line|

    line = line.gsub(" ", ",")
    puts line

    line_arr = line.split(",").reject! { |c| c.empty? }

    controller_name_val = line_arr[-1].split("#").first
    action_name_val = line_arr[-1].split("#").last.chomp
    if controller_name_val.include?("/")
      controller_name_val=controller_name_val.split("/").map{|part_controller_name| part_controller_name.capitalize}.join("::")
    else
      controller_name_val=controller_name_val.capitalize
    end
    exist_action = ShangjiebaAction.find_by_controller_name_and_action_name("#{controller_name_val}Controller",action_name_val)
    if  exist_action.nil?                
      ShangjiebaAction.create({:controller_name=>"#{controller_name_val}Controller", :action_name=>action_name_val, :request_path=>line_arr[-2], :request_method=>line_arr[-3]}
    )
    else
      puts "existing"
    end

  end  
end
  end
 
  task :clear_sku  => :environment do
     skus = Sku.last(15000)
     skus.each do |sku|
       if sku.category_id < 100

          to_be_deleted = false
          if sku.photos.empty? || sku.photos.length == 0
            to_be_deleted = true
          else
            p "photo length=", sku.photos.length, "resume"
            sku.deleted = nil
            sku.save   
          end
          
  
          if to_be_deleted
            p "destroy sku #{sku.title}, #{sku.brand.name}"
            sku.deleted = true
            sku.save
          end
       end
     end
  end
  
  task :update_sku_properties => :environment do
	spider_ids = Spider.where{template_id==893}.map(&:id)
	Sku.where{spider_id >> spider_ids}.each do |sku|
	   sku_color = sku.color
	   sku_sizes = []
	   sku_sizes = sku.sizes.split(",") if sku.sizes
	   hsku_color = {"color_names"=>[], "icon_urls"=>[]}

	   begin 
	    hsku_color = JSON.parse(sku_color) if sku_color
	   rescue=>e
	    puts e
	   end   

   if hsku_color["color_names"].empty?
     sku_property = SkuProperty.where{(sku_id==sku.id)&(property_id==2)&(value=="默认")}.first
     if sku_property.nil?
       SkuProperty.create({:sku_id=>sku.id, :property_id=>2, :value=>"默认", :color_image_url=>"默认"})
     else
       sku_properties = SkuProperty.where{(sku_id==sku.id)&(property_id==2)&(value=="默认")}
       if sku_properties.length>1
         sku_properties[1..-1].each do |sku_property|
           sku_property.destroy
         end
       end
     end
   end
   hsku_color["color_names"].each_with_index do |color_name, i|
       sku_property = SkuProperty.where{(sku_id==sku.id)&(property_id==2)&(value==color_name)}.first
    if sku_property.nil?
      SkuProperty.create({:sku_id=>sku.id, :property_id=>2, :value=>color_name, :color_image_url=>hsku_color["icon_urls"][i]})
    else
      sku_property.update_attributes({:sku_id=>sku.id, :property_id=>2, :value=>color_name, :color_image_url=>hsku_color["icon_urls"][i]})      
    end
   end
   if sku_sizes.empty?
     sku_property = SkuProperty.where{(sku_id==sku.id)&(property_id==1)&(value=="默认")}.first
     if sku_property.nil?   
       SkuProperty.create({:sku_id=>sku.id, :property_id=>1, :value=>"默认", :count=>10})
     else
       sku_properties = SkuProperty.where{(sku_id==sku.id)&(property_id==1)&(value=="默认")}
       if sku_properties.length>1
         sku_properties[1..-1].each do |sku_property|
           sku_property.destroy
         end
       end
     end
   end   
   sku_sizes.each do |sku_size|
     store_count = 10
        if sku_size.include?("(")
         store_count = 0
         sku_size = sku_size.split(" ").first
        end     
     if sku.category_id != 4 && sku.category_id != 5 && sku.category_id != 6
       if !sku.buy_url.include?("zalando.co.uk") 
	     case sku_size
	     when /32|34/
	       sku_size = 'XS'
	     when /36/
	       sku_size = 'S'
	     when /38|40/
	       sku_size = 'M'     
	     when /42/
	       sku_size = 'L'      
	     when /44|46/
	       sku_size = 'XL'               
	     end
       end
      end

     if sku.category_id != 4 && sku.category_id != 5 && sku.category_id != 6
       if sku.buy_url.include?("zalando.co.uk") 
           sku_property = SkuProperty.where{(sku_id==sku.id)&(property_id==1)&(value==sku_size)}.first
           if sku_property
             sku_property.destroy
           end
         case sku_size
         when "6"
           sku_size = 'XS'
         when /8/
           sku_size = 'S'
         when /10/
           sku_size = 'M'     
         when /12/
           sku_size = 'L'      
         when /14/
           sku_size = 'XL'      
         when "16"
           sku_size = 'XXL'                   
         end
       end
      end      


       sku_property = SkuProperty.where{(sku_id==sku.id)&(property_id==1)&(value==sku_size)}.first

	     if sku_property.nil?
	       SkuProperty.create({:sku_id=>sku.id, :property_id=>1, :value=>sku_size, :count=>store_count})
	     else
        sku_property.update_attributes({:sku_id=>sku.id, :property_id=>1, :value=>sku_size, :count=>store_count})         
	     end

     end

   end

  end
  task :update_sku_properties2 => :environment do
      agent_spider_ids = Spider.where{(is_agent==true)&(is_template==false)}.map(&:id)
      template_agent_spider_ids = Spider.where{(is_agent==true)&(is_template==true)}.map(&:id)
      all_template_agent_spider_ids = Spider.where{template_id >> template_agent_spider_ids}.map(&:id)
      all_agent_spider_ids = agent_spider_ids|all_template_agent_spider_ids

#Sku.where{(spider_id >> [52, 24, 238, 49, 50, 674, 673])&(deleted==nil)}.each do |sku|
#      spider_ids = Spider.where{template_id==685}.map(&:id)
      Sku.where{(spider_id >> all_agent_spider_ids)&(deleted==nil)}.each do |sku|
          puts sku.buy_url
           sku_color = sku.color
	   sku_sizes = []
	   sku_sizes = sku.sizes.split(",") if sku.sizes && !sku.buy_url.include?("hm.com")
           if sku.buy_url.include?("hm.com")
             sku_sizes << sku.sizes if sku.sizes
             if sku.sizes =~ /色/
               sku_sizes = []
             end
           end
	   hsku_color = {"color_names"=>[], "icon_urls"=>[]}

	   begin 
	    hsku_color = JSON.parse(sku_color) if sku_color
	   rescue=>e
	    puts e
	   end   

   if hsku_color["color_names"].empty?
     sku_property = SkuProperty.where{(sku_id==sku.id)&(property_id==2)&(value=="默认")}.first
     if sku_property.nil?
       SkuProperty.create({:sku_id=>sku.id, :property_id=>2, :value=>"默认", :color_image_url=>"默认"})
     else
       sku_properties = SkuProperty.where{(sku_id==sku.id)&(property_id==2)&(value=="默认")}
       if sku_properties.length>1
         sku_properties[1..-1].each do |sku_property|
           sku_property.destroy
         end
       end
     end
   end
   hsku_color["color_names"].each_with_index do |color_name, i|
      if sku.buy_url=~/theoutnet.cn/
        color_name = color_name.gsub(/颜色：/, "").strip
      end
       sku_property = SkuProperty.where{(sku_id==sku.id)&(property_id==2)&(value==color_name)}.first
    if sku_property.nil?
      SkuProperty.create({:sku_id=>sku.id, :property_id=>2, :value=>color_name, :color_image_url=>hsku_color["icon_urls"][i]})
    else
      sku_property.update_attributes({:sku_id=>sku.id, :property_id=>2, :value=>color_name, :color_image_url=>hsku_color["icon_urls"][i]})      
    end
   end
   if sku_sizes.empty?
     sku_property = SkuProperty.where{(sku_id==sku.id)&(property_id==1)&(value=="默认")}.first
     if sku_property.nil?   
       SkuProperty.create({:sku_id=>sku.id, :property_id=>1, :value=>"默认", :count=>10})
     else
       sku_properties = SkuProperty.where{(sku_id==sku.id)&(property_id==1)&(value=="默认")}
       if sku_properties.length>1
         sku_properties[1..-1].each do |sku_property|
           sku_property.destroy
         end
       end
     end
   end   

   sku_sizes.each do |sku_size|
     case sku.buy_url
     when /zara.cn/
       sku_size = sku_size.split(" ").first
     when /riverisland.com|dorothyperkins.com/
       sku_size = sku_size.split(" ").first if sku_size =~ /(uk)/
       sku_size = sku_size.split("-").first if sku_size =~ /-/
       sku_size = "" if sku_size =~ /select size|Choose your size/
       sku_size = sku_size.strip
       if sku.category_id != 4 && sku.buy_url.include?("madewell.com") 
           
         if sku_size == "00" || sku_size == "0" || sku_size == "24" || sku_size == "25"
           sku_size = 'XS'
         elsif sku_size == "2" || sku_size == "4" || sku_size == "26" || sku_size == "27"
           sku_size = 'S'
         elsif sku_size == "6" || sku_size == "8" || sku_size == "28" || sku_size == "29"
           sku_size = 'M'   
         elsif sku_size == "10" || sku_size == "12" || sku_size == "30" || sku_size =~ /31/
           sku_size = 'L'      
         elsif sku_size == "14" || sku_size == "16" || sku_size == "33" || sku_size =~ /32/
           sku_size = 'XL'      
         end
       end
       if sku.category_id != 4 && !sku.buy_url.include?("madewell.com") 
           
         case sku_size
         when "6"
           sku_size = 'XS'
         when "8"
           sku_size = 'S'
         when /10/
           sku_size = 'M'     
         when /12/
           sku_size = 'L'      
         when /14/
           sku_size = 'XL'      
         when /16|18/
           sku_size = 'XXL'                   
         when /20|22/
           sku_size = 'XXXL'                   
         end
       end
      if sku.category_id == 4 && sku.buy_url =~ /madewell.com/
      
        case sku_size
        when /4|4h/
          sku_size = "34"
        when /5|5h/
          sku_size = "35"
        when /6/
          sku_size = "36"
        when /6h|7/
          sku_size = "37"
        when /7h|8/
          sku_size = "38"
        when /8h/
          sku_size = "39"
        when /9|9h/
          sku_size = "40"
        when /10/
          sku_size = "41"
        when /10h|11/
          sku_size = "42"
        when /11h|12/
          sku_size = "43/44"
        end
      end
      if sku.category_id == 4 && sku.buy_url =~ /dorothyperkins.com/
      
        case sku_size
        when /3/
          sku_size = "34/35"
        when /4/
          sku_size = "36"
        when /5/
          sku_size = "37"
        when /6/
          sku_size = "38"
        when /7/
          sku_size = "39"
        when /8/
          sku_size = "40"
        when /9/
          sku_size = "41/42"
        end
      end
     else
     end
     store_count = 10
      if !sku_size.strip.empty? 
        
       sku_property = SkuProperty.where{(sku_id==sku.id)&(property_id==1)&(value==sku_size)}.first

	     if sku_property.nil?
	       SkuProperty.create({:sku_id=>sku.id, :property_id=>1, :value=>sku_size, :count=>store_count})
	     else
        sku_property.update_attributes({:sku_id=>sku.id, :property_id=>1, :value=>sku_size, :count=>store_count})         
	     end
      end

   end
   end
  end

end
