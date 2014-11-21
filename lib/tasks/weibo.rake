# encoding: utf-8
require 'rmmseg'

RMMSeg::Dictionary.load_dictionaries


def simplify(s)
    s = s.downcase
    s = s.gsub /[\[\]]/, ''
    s.gsub /\s+/, ''
end


def is_baobei(doc)
  if not doc["imgsrc"] or doc["imgsrc"] == ""
    return false
  end
  aa = simplify(doc['desc'])
  btag = doc['pattern']
  return true unless btag
  #p "#{btag} vs #{aa}"
  if not btag or btag == ""
    return true
  end
  btag.split('|').each do |tag|
    tag = simplify(tag)
    if aa.index(tag)
      return true
    end
  end
  return false
end



def is_ok(doc, tags = [])
    content = simplify(doc['desc'])
    if content !~ /\d+折/ and content !~ /(满)?\d+(立)?减\d+/ and content !~ /优惠/ and content !~ /打折/
       return false
    end

    hit = 0
    doc["tags"] = []
    if true
      tags.each do |tag|
        algor = RMMSeg::Algorithm.new(doc['desc'])
        loop do
          tok = algor.next_token
          #p tok.text +" vs " + tag 
          break if tok.nil?
          if tok.text.downcase == tag
            puts "#{tok.text} [#{tok.start}..#{tok.end}]"
            doc["tags"] << tag
          end
        end
      end
    end
    p doc
    p doc["tags"]
    #return true if doc["tags"].length > 0
    return true
end


def format_date(doc)
  year = Time.new.strftime("%Y")
  month = Time.new.strftime("%m")
  publish = doc["time"].split(" ")[0]

  se = []
  [doc['start_date'], doc['end_date']].each do |ds|
    #print "fuc", publish, "\n"
    if not ds
      next
    end
    if ds.index("即日")
      ds = publish
    end
    ds = ds.gsub /中旬/, "15日"

    ds = ds.gsub /年|月|[\.\/]/, "-"
    ds = ds.gsub /日/, ""
    len = ds.split('-').length
    if len == 2
      ds = "#{year}-#{ds}"
    elsif len == 1
      ds = "#{year}-#{month}-#{ds}"
    end
    se << "#{ds}"
  end
  doc["start_date"] = se[0]
  doc["end_date"] = se[1]
  if doc["start_date"]  == ""
    doc["start_date"] = publish
  end
end


def parse_date(doc)
  #print "Xxxxxxx pase date \n"
  #content = simplify(doc["desc"])
  content = doc["desc"]
  year = Time.new.strftime("%Y")
  today = Time.new.strftime("%Y-%m-%d")
  start_date = Date.parse( doc['time'].split(" ")[0] )
  end_date = 7.days.since( start_date )

  mat0 = /(\d+月\d+日|即日)起/.match(content)
  if mat0
    doc["start_date"] = mat0[1]
  end

  mat = /(\d+月\d+日|即日起)[-至到\~]((\d+月)?(\d+日|中旬))/.match(content)
  if mat
    print "!!!!111", mat[1], "->", mat[2], "\n"
    doc["start_date"] = mat[1]
    doc["end_date"] = mat[2]
  else
    mat1 = /(\d+[\.\/]\d+|即日起)[-至到\~]((\d+)?[\.\/](\d+))/.match(content)
    if mat1
      print "!!!!222", mat1[1], "->", mat1[2], "\n"
      doc["start_date"] = mat1[1]
      doc["end_date"] = mat1[2]
    end
  end
  format_date(doc)
  #p doc

'''
  a = "即日起至7月中旬"
  a1= "6月28-7月2日"
  a2 = "即日起-7/28"
  b = "部分商品3--5折"
  b1 = "6/27~7/31"
  "7月1日至7月14日"
  "7/2-7/8"
  "7月5日~8日"
7月4日-7月17日
7月11至17日
 7.5-7.31
7.1-7.24
7月1日至7月14日 
7月2日下午14:00-18:00
'''
end


def parse_title(doc)
    content = simplify(doc["desc"])
    mat=/(全场|全場)[\d\.]+(折|元)(起)?/.match(content)
    if mat
      return mat[0]
    end
    mat=/(部分|新款|新品|低至|精选|全场|全場)(.*?)\d折/.match(content)
    if mat
      return mat[0]
    end
    mat=/(一|1)件(.*?)折(.*?)(2|二|两)件(.*?)折/.match(content)
    if mat
      return mat[0]
    end
    mat=/(全场|全場|部分)?(满)\d+(元?)减(\d+)/.match(content)
    if mat
      return mat[0]
    end

    mat=/(全场|全場|部分)?\d+(元?)减(\d+)/.match(content)
    if mat
      return mat[0]
    end

    mat=/[\d\.\~到-]+折/.match(content)
    if mat
      return mat[0]
    end

    mat=/一口价\d+元/.match(content)
    if mat
      return mat[0]
    end
end



def process_fn(inst, source, pattern, days_ago, is_discount=false, tags=[])
    redis =  Redis.new(:host => '114.80.100.12', :port => 6379)
    source_weibo_brand = redis.lrange("weibo_brand_#{source}", 0, -1)
    return if source_weibo_brand.empty?
    
    last_time = nil

    source_weibo_brand.each do |line|
      begin
        items  = line.strip().split("\t")
        doc = {}
        if items.size >= 4
          doc["DOCID"] = "weibo"+items[0]
          doc["desc"] = items[2] 
          unless is_discount
            next if Sku.find_by_docid(doc["DOCID"])
          else
            discount = Discount.find_by_docid(doc["DOCID"])
            if discount && discount.photos.length == 0
              doc["imgsrc"] = items[3]
              doc["imgsrc"].split('|').each do |img|
                Photo.attach(img, discount)
              end
            end
          end
          next if discount

          doc["time"] = items[1]
          doc["desc"] = items[2]
          doc["imgsrc"] = items[3]
          doc["Url"] = "http://weibo.com/#{source}/#{items[0]}"
          doc["pattern"]  = pattern

          title_str = doc["desc"].gsub(/(.*)#(.*?)#(.*)/, '\2')
          if title_str.nil? || title_str.empty?
            title_str = doc["desc"].gsub(/[# ,\.】]+/, "")[0..10]
          end
          doc["Title"] = title_str
       
          doc_time = Time.parse(doc["time"])
          if last_time.nil? || ( doc_time && doc_time > last_time)
            if doc_time && days_ago.days.since(doc_time) > Time.now
              
              unless is_discount
                if is_baobei(doc)
                  sku = inst.skus.new(:docid => doc["DOCID"], :title => title_str, :desc => doc["desc"], :level => 4, :category_id => 3)
                  if sku.save
                     doc["imgsrc"].split('|').each do |img|
                       Photo.attach(img, sku)
                     end
                  end
                end
              else
                if inst.instance_of?(Shop) && is_ok(doc, tags)
                  parse_date(doc)
                  doc['title'] = parse_title(doc)
                  p doc
                  discount = inst.discounts.new(:title=>doc['title'], :description=>doc['desc'], :publish=>doc['time'],  :from=>doc['from'], \
:docid=>doc['DOCID'], :source => source, :start_date=>doc['start_date'], :end_date=>doc['end_date'], :reason => doc['tags'].join(' ') )

                  if discount.save
                     doc["imgsrc"].split('|').each do |img|
                       Photo.attach(img, discount)
                     end
                  end
                end

                if inst.instance_of?(Brand)
                  if is_baobei(doc)
                    start_date = Date.parse( doc['time'].split(" ")[0] )
                    end_date = 7.days.since( start_date )

                    discount = inst.discounts.new(:docid => doc["DOCID"], :title => title_str, :description => doc["desc"], :publish=>doc['time'], :source => source, :from=>doc['from'], :start_date=> start_date, :end_date => end_date )
                    p discount
                    if discount.save
                       doc["imgsrc"].split('|').each do |img|
                         Photo.attach(img, discount)
                       end
                    end
                  end 
                end   

              end

            end
          end

          last_time = doc_time
        end
      rescue => e
        p e.to_s
      end
    end
end


namespace :weibo do
  task :mall_discount => :environment do
   tags = []
   Brand.where{level >= 1}.each do |b|
      brand_c_name = b.c_name
      brand_e_name = b.e_name
      tags << brand_c_name if brand_c_name && !brand_c_name.strip.empty?
      tags << brand_e_name if brand_e_name && !brand_e_name.strip.empty?
   end
   p tags 
   Shop.where{shop_type == 11}.each do |s|
      shop_weibo = s.weibo
      if shop_weibo && !shop_weibo.empty?
        p shop_weibo
        process_fn(s, shop_weibo, '', 7, true, tags)   
      end
   end
  end


  task :brand_sku => :environment do
    Brand.where{level == 4}.each do |b|
      p b.name, b.level
      last_sku = b.skus.last
      if last_sku.from == "homepage"
        b.level = 5
        b.save
        next
      end

      ct = b.crawler_templates.first 
      next unless ct
      process_fn(b, ct.source, ct.pattern, 15, false)
    end
  end


  task :brand_discount => :environment do
    Brand.where{level > 4}.each do |b|
      ct = b.crawler_templates.first
      next unless ct
      process_fn(b, ct.source, ct.pattern, 7, true)
    end
  end

end
