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


def process(doc, update=false)
end


namespace :matter do

  task :import, [:spider_id] => :environment do |t, args|
     @redis =  Redis.new(:host => 'localhost', :port => 6379)
     
     spider_id = args[:spider_id]
     spider = Spider.find spider_id
     brand_id = spider.brand.id

     if true 
       spider_pages = spider.get_spider_pages
       spider_pages.each do |c|
         page_id = c.id
         pkey = "brand_#{brand_id}_spider_#{spider_id}_spider_pages_#{page_id}"
         lks = @redis.lrange(pkey, 0, -1)
         brand_cat_list_length = lks.length
         p pkey,lks.length

         next if brand_cat_list_length == 0

         lks.each do |link| 
           #link = @redis.rpop(pkey)
           begin
             p link
             next if link.nil?
             link_docid = make_docid(link)
             doc_yml = @redis.get link_docid
             next if doc_yml.nil?
             
             doc = YAML::load( doc_yml )
             doc['docid'] = link_docid
             doc['link'] = link
             doc['category_id'] = c.parent_id
             u = User.create_by_brand(brand_id)
             doc['user_id'] = u.id
             doc['page_id'] = page_id
             doc['spider_id'] = spider_id
             doc['sub_category_id'] = c.get_category(u.id).id
             #========

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
