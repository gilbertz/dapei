# -*- encoding : utf-8 -*-

class Spider < ActiveRecord::Base
  belongs_to :brand, :inverse_of=>:spiders
  has_many :spider_pages

  def get_spider_pages
    SpiderPages.where(:spider_id => self.id)
  end


  def get_docs
    doc_dict = {}

    spider_pages = self.get_spider_pages
    spider_pages.each do |c|
      page_id = c.id
      pkey = "brand_#{brand_id}_spider_#{spider_id}_spider_pages_#{page_id}"
      lks = @redis.lrange(pkey, 0, -1)
      brand_cat_list_length = lks.length
      p pkey,lks.length

      next if brand_cat_list_length == 0
      
      docs = []
      lks.each do |link|
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
        doc['sub_category_id'] = c.get_category(u.id).id
        docs << doc
      end
      doc_dict[page_id] = docs
    end
    doc_dict
  end


  def crawler_command 
    `sshpass -p '#{SPIDER_PASS}' ssh -o StrictHostKeyChecking=no #{SPIDER_USER}@#{SPIDER_IP} 'cd /data/spider/ && /bin/bash ./spider.sh #{self.id} > /tmp/spider_#{spider_id}.log'`

  end

  def invert_state
    if self.stop
      self.stop = false
    else
      self.stop = true
    end
    self.save
  end

  def stop_status
    if self.stop
      '停止'
    else
      '活动'
    end
  end

  def get_crawled_status(cat_id)
     redis =  $redis_crawler
     len = 0
     if self.brand
       pkey = "brand_#{self.brand.id}_product_pages_#{cat_id}"
       lks = redis.lrange(pkey, 0, -1)
       len = lks.length
     end
     return len
  end 

  def get_domain(url)
    if url
      parts = url.gsub("http://", "").split("/")
      if parts.length  > 0
        return parts[0].gsub("www.", "")
      end
    else
      ""
    end
  end
 
  def spider_domain
    categories = Category.where("id >= 3").where("id < 15")
    start_page = ""
    categories.each do |cat|
      tag = ""
      tag = "_#{cat.id}" if cat.id > 3
      start_page += eval "self.start_page#{tag}.to_s"
    end
    domain = ""
    domain = start_page.split('/')[2] if start_page and start_page.split('/').length >= 3
    domain
  end

  def spider_pic_index
    return self.pic_index if self.pic_index
    if self.template_id and self.template_id.to_i > 0 
       return Spider.find_by_id(self.template_id).pic_index
    end
  end

  def spider_show_pic_index
    return self.show_pic_index if self.show_pic_index
    if self.template_id and self.template_id.to_i > 0
       return Spider.find_by_id(self.template_id).show_pic_index
    end
  end

  def is_net_porter
    self.template_id and  self.template_id == 111
  end

  def template_spider
    if self.template_id && self.template_id > 0
      self.class.find_by_id(template_id)
    else
      self
    end
  end
 
  def get_start_page(id)
    if id == 3
      self.start_page
    else
      eval "self.start_page_#{id}"
    end
  end

  def parse(doc)
    ndoc = {}
    
    ndoc[:docid] = Digest::MD5.hexdigest( doc["url"] )
    ndoc[:from]  = "homepage/mywish"
    ndoc[:title] = doc["title"]
    ndoc[:price] = doc["price"]
    ndoc[:origin_price] = doc["origin_price"]
    ndoc[:tags]  = doc["tags"]
    ndoc[:pno] =  doc["pno"]
    ndoc[:color] = doc["color"]
    ndoc[:color_url] = doc["color_url"]
    ndoc[:sizes] = doc["sizes"]

    domain = get_domain(doc['url'])

    #ndoc[:desc]  = doc["desc"]
    doc["brand"] = doc["brand"].downcase.gsub(" ", "")
    brand = Brand.new.by_name(doc["brand"])
    
    bit = nil
    if ndoc[:title]
      pb = ndoc[:title].split(/\|- /)
      if pb[0]
        bt=  pb[0].downcase.gsub(" ", "")
      end
    end
    
    if brand 
      ndoc[:brand_id] = brand.id
    elsif bt and  Brand.new.by_name(bt)
      ndoc[:brand_id] = Brand.new.by_name(bt).id
    elsif Brand.find_by_domain(domain)
      ndoc[:brand_id] = Brand.find_by_domain(domain).id
    else
      ndoc[:brand_id] = 1071
    end

    if ndoc[:brand_id] == "18"
      if ndoc[:title].downcase.index("shoebox")
          ndoc[:brand] = "shoebox"
          ndoc[:brand_id] = "1035"
      end
    end

    ndoc[:publish] = Time.now().to_s
    ndoc[:buy_url] = doc["url"]

    (1..4).each do |i|
      if doc["desc#{i}"]and doc["desc#{i}"] != ""
        ndoc[:desc] += doc["desc#{i}"]
      end
    end

    ndoc[:category_id] = 3
    if ndoc[:title]
      if ndoc[:title].index("鞋")
        ndoc[:category_id] = 4
      elsif ndoc[:title].index("搭配")
        ndoc[:category_id] = 2
      elsif ndoc[:title].index("包") and not ndoc[:title].index("包臀")
        ndoc[:category_id] = 5
      elsif ndoc[:title].index("饰品") or ndoc[:title].index("腰带") or ndoc[:title].index("眼镜") or ndoc[:title].index("钥匙扣")
        ndoc[:category_id] = 6
      end
    end

    imgs = []
    doc["imgs"].each do |img|
        if doc["brand_id"] == "441"
          img = img.gsub(/&w=\d+(.*)$/, "").gsub(/sites\/default\/tumb.php\?src=/ ,"")
        end

        if doc["brand_id"] == "104"
          img = img.gsub(/\/S3\//, "/S20/")
        end

        if doc["brand_id"] == "299"
          img = img.gsub(/\_15\_/, "_19_")
        end

        if doc["brand_id"] == "505"
          img = img.split("'")[3]
        end

        img = img.gsub(/\?(.*)$/, "")
        img = img.gsub(/\$pd\_(.*)\$/,"$pd_full$")
        img = img.gsub("_zoomthumb$","_pdpdetail$")
        img = img.gsub(/jpg_(\d+)x(\d+).jpg/,"jpg")
        img = img.gsub(/_s_s.jpg/,".jpg") # for ca
        img = img.gsub(/--w_(\d+)_h_(\d+)/,"")
        img = img.gsub(/\/S3\//,"/S20/") #for mango
        img = img.gsub(/thumbnail\/\d+x\d+/,"image/")#for etam
        #img = img.gsub(/image\/\d+x\d+/,"img/")#for gap
        img = img.gsub(/tumb.php\?src=\/sites\/default/, "") #for katespade
        imgs << img
    end
    ndoc[:imgs] = imgs
    ndoc[:raw_imgs] = imgs.join("|")
    ndoc 
  end

end
