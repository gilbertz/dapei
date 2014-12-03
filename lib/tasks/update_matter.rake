# encoding: utf-8
require 'thread'
require 'awesome_print'
require 'taobaorb'
require 'xmlsimple'

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


def process(doc, update=false)
end


namespace :matter do

  task :import, [:brand_id] => :environment do |t, args|
     @redis =  Redis.new(:host => 'localhost', :port => 6379)
     
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
         p pkey,lks.length

         next if brand_cat_list_length == 0

         lks.each do |link| 
           #link = @redis.rpop(pkey)
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
             doc['docid'] = link_docid
             doc['link'] = link
             p doc
             Matter.create_from_hash(doc)
             #process( make_doc(doc) )
             #@redis.del link_docid
           rescue => e
             p e.to_s
           end
         end

       end
      end
  end

  task :import_all => :environment do
  end


end
