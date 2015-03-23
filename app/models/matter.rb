# -*- encoding : utf-8 -*-
class Matter < ActiveRecord::Base
  #belongs_to :sku
  belongs_to :photo
  belongs_to :user
  belongs_to :brand
  belongs_to :spider

  has_one :matter_info
  belongs_to :category

  include Sjb::Likeable
  include Sjb::Commentable

  acts_as_taggable
  acts_as_commentable

  accepts_nested_attributes_for :matter_info

  acts_as_api
  api_accessible :public, :cache => 180.minutes do |t|
    t.add :id, :as => :object_id
    t.add :title, :as => :title
    t.add :desc
    t.add lambda { |item| item.price.to_s }, :as => :price
    t.add lambda { |item| item.origin_price.to_s }, :as => :origin_price
    t.add lambda { |item| item.brand_name.to_s }, :as => :brand_name
    t.add lambda { |item| item.brand_id.to_s }, :as => :brand_id
    t.add lambda { |item| item.category_id.to_s }, :as => :category_id
    t.add lambda { |item| item.image_name.to_s }, :as => :thing_id
    t.add lambda { |item| item.img_url }, :as => :img_url
    t.add lambda { |item| item.get_small_jpg.to_s }, :as => :small_jpg
    t.add lambda { |item| item.get_big_png.to_s }, :as => :big_png
    t.add lambda { |item| item.comments_count.to_i.to_s }, :as => :comments_count
    t.add lambda { |item| item.likes_count.to_i.to_s }, :as => :likes_count
    t.add lambda { |item| item.get_dispose_count.to_i.to_s }, :as => :dispose_count
    t.add lambda { |item| item.like_id.to_s}, :as => :like_id
    t.add lambda { |item| item.created_at.to_s }, :as => :created_at
    t.add lambda { |item| item.updated_at.to_s }, :as => :updated_at
    t.add :share_url
    t.add :share_img
    t.add :get_buy_status, :as => :buy_status
    t.add lambda { |item| item.link.to_s }, :as => :buy_url
    t.add :buy_domain, :as => :buy_domain
    t.add lambda { |item| item.width.to_s }, :as => :w
    t.add lambda { |item| item.height.to_s }, :as => :h
    t.add lambda { |item| item.level.to_s }, :as => :level
  end


  scope :liked_by, lambda { |user|
    joins(:likes).where(:likes => {:user_id => user.id}).order("likes.created_at desc")
  }

  scope :created_by, lambda { |user|
    where("user_id = #{user.id}").order("created_at desc")
  }

  def get_buy_status
    return '0' if self.deleted
    return '0' if self.link.blank?
    return '1'
  end  
 

  def buy_domain
    if self.link
      self.link.gsub(/https?:\/\//, "").split("/")[0]
    else
      ""
    end
  end

  def recommend
    self.level = 2
    self.save
  end


  def unrecommend
    self.level = 0
    self.save
  end


  def share_img
    self.get_big_png
  end
 
  def sub_category
    if self.sub_category_id
      Category.find_by_id(self.sub_category_id) 
    end
  end


  def like_id
    return 0 if not User.current_user
    like=Like.find_by_user_id_and_target_id_and_target_type(User.current_user.id, self.id, "Matter")
    if like
      like.id
    else
      0
    end
  end

  def get_user
    if self.user_id
      User.find_by_id( self.user_id )
    end
  end

  def brand_name
    if self.brand
      self.brand.display_name
    else
      ''
    end
  end

  
  def user_url
    if self.user
      self.user.url
    else
      ""
    end
  end

  def user_name
    if self.user
      self.user.display_name
    else
      ""
    end
  end

  def user_img_small
    if self.user
      self.user.display_img_small
    else
      "http://www.shangjieba.com/assets/img.jpg"
    end
  end


  def share_url
    "http://m.dapeimishu.com:9090/matters/#{self.id}/view_show"
  end

  def share_img
    self.get_big_png
  end
  

  def get_dapeis(page=1, limit=8)
    dapeis = []
    dapei_item_infos = DapeiItemInfo.where(:matter_id => self.id).order('created_at desc').page(page).per(limit)
    dapei_item_infos.each do |di|
      dinfo = di.dapei_info
      if dinfo
        dapeis <<  dinfo.dapei if dinfo.dapei
      end
    end
    dapeis.uniq 
  end

  def get_dapeis_count
    self.get_dapeis(1, 1000).length
  end


  def is_owned
    return 0 if not User.current_user
    return 1 if  User.current_user.id == self.user_id
    return 0
  end

  def sync_tags
  end

  def colors
    color_arr = []
    ['color_one_id', 'color_two_id', 'color_three_id'].each do |c|
       color = eval "Color.find_by_id(self.#{c})"
       color_arr << color.color_16 if color
    end
    color_arr
  end


  def make_color
      url = COLOR_EXTRACTOR_URL
      m = self 
      params = {:image_url => m.matter_img_url }
      res = RestClient.get url, {:params => params }
      res = JSON.parse(res)
      colors = res["colors"]
      color_arr = colors.split(" ")
      if color_arr.size == 3
          color_arr.each_with_index do |c, index|
            co = Color.find_by_color_16(c)
            unless co.blank?
              if index == 0
                m.color_one_id = co.id
              elsif index == 1
                m.color_two_id = co.id
              elsif index == 2
                m.color_three_id = co.id
              end
            end
          end
          m.save
      end
  end

  def get_first_color
    #self.make_color unless self.color_one_id
    
    c = Color.find_by_id(self.color_one_id)
    if c 
      return c.color_16
    else
      return "000000"
    end
  end

  def get_second_color
    c = Color.find_by_id(self.color_two_id)
    if c
      return c.color_16
    else
      return "000000"
    end
  end
 
  def origin_img
    if self.sjb_photo_id
      p = Photo.find_by_id(self.sjb_photo_id)
      p.url if p
    end
  end

  def img_url

        unless self.remote_photo_path.blank? or self.remote_photo_name.blank?
                self.remote_photo_path + self.remote_photo_name
        else
                 AppConfig[:remote_image_domain] + "/uploads//cgi/img-thing/mask/1/size/orig/tid/#{self.image_name}.png"
        end

  end


  def matter_img_url(png=true)
      if png
          AppConfig[:remote_image_domain] + "/uploads/cgi/img-thing/mask/1/size/orig/tid/#{self.image_name}.png"
      else
          AppConfig[:remote_image_domain] + "/uploads/cgi/img-thing/size/orig/tid/#{self.image_name}.jpg"
      end

  end


  def fix_img_size
      p self.id, self.image_name
      url = self.matter_img_url
      path = "/var/www/shangjieba/public/uploads/cgi/img-thing/mask/1/size/orig/tid/#{self.image_name}.png"    
      if not FileTest::exist?(path)
        `wget #{self.matter_img_url} -O #{path}`
      end      

      sz = File.size(path)   
      if sz < 500  
        self.dump  
      else
        image = MiniMagick::Image.open( url )
        w = image[:width].to_i
        h = image[:height].to_i
        p "#{self.width}*#{self.height}", "  => "
        self.width = w
        self.height = h
        p "!!new #{w}*#{h}"
        self.save
      end
  end


  
  def img_urls
    img_urls = Array.new
    temp={:img_url=>self.matter_img_url, :width=>self.width.to_s, :height=>self.height.to_s}
    img_urls<<temp
    img_urls
  end

  
  def to_jq_upload
    {
      "object_id" => self.id.to_s,  
      "name" => self.image_name.to_s,
      "category_id" => self.category_id.to_s,
      "thing_id" => self.image_name.to_s,
      "url" => self.img_url.to_s,
      "thumbnail_url" => self.img_url.to_s,
      "width" => self.width.to_s,
      "height" => self.height.to_s,
      "result" =>"0"
    }
  end

  
  def get_item_buy_domain
    self.buy_domain.to_s
  end

  def get_item_buy_url
    self.link.to_s
  end

  def get_item_title
    ''
    #self.title.to_s
  end

  def get_item_price
    self.price.to_s
  end

  def incr_and_get_dispose_count
    self.incr_dispose
    self.get_dispose_count
  end


  def get_dispose_count
    if $redis.get("matter_#{self.id}")
      $redis.get("matter_#{self.id}")
    else
      self.dispose_count
    end
  end


  def incr_dispose
    key = "matter_#{self.id}"
    $redis.incr(key)
  end


  def get_small_jpg
    AppConfig[:remote_image_domain] + "/uploads//cgi/img-thing/size/s/tid/#{self.image_name}.jpg" 
  end

  def get_big_png
    AppConfig[:remote_image_domain] + "/uploads//cgi/img-thing/mask/1/size/orig/tid/#{self.image_name}.png" 
  end


  def self.create_from_hash(doc)
    if doc['dp_imgs']
      doc['dp_imgs'].each do |img|
        self.by_img(img, doc)
      end
    end
    p '1'
    spider = Spider.find doc['spider_id']
    matter_rule = spider.matter_rule 
    
    if matter_rule == 'tmall'
    #  Matter.by_img(doc['imgs'][0], doc)
    end
    p '2'   
    if matter_rule == 'hm'
      Matter.by_img(doc['imgs'][0], doc)
      Matter.by_img(doc['imgs'][1], doc) 
    end
     
    if matter_rule == 'ochirly'
      Matter.by_img(doc['imgs'][0], doc)
    end

    p '3'

  end


  def format_price(price)
    price.gsub('¥', '').gsub('￥', '')
  end

  
  def self.by_img(img, doc)
    p 'by_img'
    p = Photo.attach(img)
    p p
    return unless p
    m = Matter.find_by_sjb_photo_id(p.id)
    unless m
      m = Matter.new
    end
    m.sjb_photo_id = p.id
    m.title = doc['title']
    m.desc = doc['desc']
    m.category_id = doc['category_id']
    m.brand_id = doc['brand_id']
    m.user_id = doc['user_id']
    m.spider_id = doc['spider_id']
    m.sub_category_id = doc['sub_category_id']
    m.link = doc['link']
    m.docid = doc['docid']
    m.price = format_price( doc['price'] )
    m.origin_price = format_price( doc['origin_price'] ) if doc['origin_price']
    p '###############################################'
    p doc['sub_category_id']
    m.save
    p '========================='
    p m.sub_category_id
  end
 

  def self.from_sku(sku, spider)
    pic_index = spider.pic_index
    if sku.category_id == 4 and spider.shoe_pic_index
      p "old=#{pic_index}"
      pic_index = spider.shoe_pic_index
      #p pic_index, sku.id 
    end

    if sku.category_id == 5 and spider.bag_pic_index
      p "old=#{pic_index}"
      pic_index = spider.bag_pic_index
    end

    if sku.category_id == 6 and spider.peishi_pic_index
      p "old=#{pic_index}"
      pic_index = spider.peishi_pic_index
    end

    return if pic_index >= 0 and sku.photos.length-1 < pic_index
    return if pic_index < 0  and sku.photos.length < -1 * pic_index

    #p sku.brand_name, pic_index

    photo = sku.photos[pic_index]
    photo_id =photo.id
    photo.is_send = 1
    photo.save

    m = Matter.find_by_sjb_photo_id(photo_id)
    return m if m
    
    matter = Matter.new
    matter.source_type = 1
    matter.sjb_photo_id = photo_id
    matter.sku_id = sku.id
    matter.category_id = sku.category_id
    matter.save
    return matter
 end


 def self.build(user_id, image_data, image_type, file_data=nil)
    m = Matter.new
    #上传
    m.source_type = 4
    m.is_cut = 0
    m.category_id = 100
    m.user_id = user_id

    unless file_data
      file_type = image_type
      bi_image=Base64::decode64( image_data )
    else
      file_type  = file_data.original_filename.split(".").last
      bi_image = file_data.read
    end

    local_path = "/var/www/shangjieba/public/uploads/matters/"
    new_str = Time.now.to_i.to_s + ((100..999).to_a.shuffle[0].to_s)
    if file_type == "jpg" or file_type == "png"
      local_file_name = new_str + "." + file_type
      local_file = local_path + local_file_name
      File.open(local_file, "wb") { |f| f.write( bi_image ) }
      m.local_photo_path = local_path
      m.local_photo_name = local_file_name
      m.image_name = new_str

      if m.save
        Like.create({:target_type=>"Matter", :target_id=>m.id, :user_id => user_id})
        m.dump(false)
        return m
      end
    end
 end

 
 def dump(kt=true)
    #下载到本地的文件目录
    puts "---------------begin----------------------"

    # sjb_dir = "/var/www/shangjieba/"
    sjb_dir = "#{Rails.root}/"
    local_path = "/var/local/"
    #切出的背景图路径
    bg_image = "/home/local/bg.jpg"

    #图片取色处理程序目录
    image_dispose_color = "/var/ImageDispose/extract_color"
    #图片抠图处理程序目录

    #image_dispose_int = "/var/ImageDispose/image_interesting_new"
    #
    #image_dispose_int = "/var/ImageDispose/new_simple_interesting"
    image_dispose_int = "/var/ImageDispose/simple_interesting"
    #image_dispose_int = "/var/ImageDispose/simple_interesting_1"

    # small jpg thumb
    polyvore_small_jpg_152 = "public/cgi/img-thing/size/m/tid/"

    # 小图jpg固定路径
    polyvore_small_jpg = "public/cgi/img-thing/size/s/tid/"
    # 大图PNG固定路径
    polyvore_big_png = "public/cgi/img-thing/mask/1/size/orig/tid/"
    # 大图JPG固定路径
    polyvore_big_jpg = "public/cgi/img-thing/size/orig/tid/"

    image_big_png_save_to = sjb_dir + polyvore_big_png
    image_big_jpg_save_to = sjb_dir + polyvore_big_jpg
    image_small_jpg_save_to = sjb_dir + polyvore_small_jpg

    puts "---------------check dir is exist? ---------------"
    
    unless Dir.exist?(image_big_png_save_to)
      FileUtils.mkdir_p(image_big_png_save_to)
      puts "--------------- create dir #{image_big_png_save_to}---------------"
    end
    
    unless Dir.exist?(image_big_jpg_save_to)
      FileUtils.mkdir_p(image_big_jpg_save_to) 
      puts "--------------- create dir #{image_big_jpg_save_to}---------------"
    end

    unless Dir.exist?(image_small_jpg_save_to)
      FileUtils.mkdir_p(image_small_jpg_save_to)
      puts "--------------- create dir #{image_small_jpg_save_to}---------------"
    end

    m = self

     begin

      #puts "----------------------------matter----------------"

      #puts m.inspect

      if m.sjb_photo_id.blank? and m.source_type.to_i == 4
        p_url = m.local_photo_path + m.local_photo_name
        remote_photo_name = m.local_photo_name
      else
        p = Photo.find_by_id(m.sjb_photo_id)

        if p.blank?
          return
        end

        m.remote_photo_path = p.remote_photo_path
        m.remote_photo_name = p.remote_photo_name

        p_url = p.url

        remote_photo_name = p.remote_photo_name
      end


      p_data = open(p_url)
      #p_data = open("#{m.remote_photo_path}#{m.remote_photo_name}")

      #下载到本地的文件名称
      local_name = remote_photo_name
      #下载文件到本地等待处理
      File.open("#{local_path}#{local_name}", "wb") do |file|
        file.write p_data.read
      end

      disposed_image_name = remote_photo_name

      #日期加上随机3位数字 生成图片名称
      new_str = Time.now.to_i.to_s + ((100..999).to_a.shuffle[0].to_s)
      
      #new_name = new_str + "." +items["0"]['name'].split(".").last
      new_name_png = new_str + ".png"
      new_name_jpg = new_str + ".jpg"
      #PNG图片全路径 大图
      new_image_png = "#{image_big_png_save_to}#{new_name_png}"
      new_image_png_2 = "#{image_big_png_save_to}#{new_str}"

      new_image_jpg_big = "#{image_big_jpg_save_to}#{new_name_jpg}"
      new_image_jpg_big_2 = "#{image_big_jpg_save_to}#{new_str}"

      #JPG  小图 50x54
      new_image_jpg = "#{image_small_jpg_save_to}#{new_name_jpg}"
      new_image_jpg_2 = "#{image_small_jpg_save_to}#{new_str}"

      #PNG 图片生成
      #image = MiniMagick::Image.open("#{local_path}#{local_name}")

      l_image = local_path + local_name

      puts "------------------write #{new_image_jpg_big}------------"
      #抠图jpg

      # data = File.open(l_image, "rb").read

      # File.open(new_image_jpg_big, "wb") do |f|
      #   f.write data
      # end

      `cd #{image_dispose_int} && ./imageroi_exe #{l_image} #{new_image_jpg_big_2} 0`

      `cd #{image_dispose_int} && ./imageroi_exe #{l_image} #{new_image_jpg_big_2} 1`
      #image.write new_image_jpg_big

      puts "------------------write #{new_image_png}------------"
      #image.write new_image_png
      if kt
        p "cd #{image_dispose_int} && ./imageroi_exe #{l_image} #{new_image_png_2} 1"
        `cd #{image_dispose_int} && ./imageroi_exe #{l_image} #{new_image_png_2} 1`
      else
        p "cd /var/ImageDispose/jpg2png && ./jpg2png #{new_image_jpg_big} #{new_image_png}"
        `cd /var/ImageDispose/jpg2png && ./jpg2png #{new_image_jpg_big} #{new_image_png}` 
      end

      #生成小图
      #puts "------------------write #{new_image_jpg}-----------------"
      #image.write new_image_jpg
      sleep(1)
      `chmod -R 1777 #{new_image_jpg_big}`
      sleep(1)
      image = MiniMagick::Image.open(new_image_jpg_big)

      w = image[:width].to_i
      h = image[:height].to_i
      # small jpg  152*152
      small_jpg_152_file = sjb_dir + polyvore_small_jpg_152 + new_str + ".jpg"

      if w > h
         new_w = 152
         new_h = (152.00/w)*h
      else
         new_h = 152
         new_w = (152.00/h)*w
      end

      image.resize  "#{new_w}x#{new_h}"
      image.write small_jpg_152_file
      image.write new_image_jpg


      #图片相对sjb目录路径 PNG
      #new_image_png_xiangdui = "#{polyvore_big_png}#{new_name_png}"
      #图片相对sjb目录路径 JPG
      #new_image_jpg_xiangdui = "#{polyvore_big_jpg}#{new_name_jpg}"

      #对处理后的图片取色获取信息

      #puts "get colors"
      #puts "cd #{image_dispose_color} && ./extract_color color1.txt #{new_image_png}"

      #colors = `cd #{image_dispose_color} && ./extract_color color1.txt #{new_image_png}`

      #color_arr = colors.split(" ")

      #puts "----------color_arr-----------"
      
      #puts color_arr.inspect

      #if color_arr.size == 3
      #  color_arr.each_with_index do |c, index|
      #    co = Color.find_by_color_16(c)
      #
      #    puts "------------color----------------"
      #    puts co.inspect
      #
      #    unless co.blank?
      #      if index == 0
      #        m.color_one_id = co.id
      #      elsif index == 1
      #        m.color_two_id = co.id
      #      elsif index == 2
      #        m.color_three_id = co.id
      #      end
      #    end
      #  end
      #else
      #  puts "------------------get colors failed------------------"
      #end
      #color_str = "color_one color_two color_three"
      #color_str_arr = color_str.split(" ")

      #生成50x54的JPG格式的小图

      ##写入相应的信息入库
      #m.color_one_id = color_one
      #m.color_two_id= color_two
      #m.color_three_id = color_three
      m.image_name = new_str
      m.local_photo_name = local_name
      m.local_photo_path = image_big_png_save_to
      m.local_cut_photo_path = polyvore_big_png
      m.local_cut_photo_name = new_name_png
      m.is_cut = 1
      m.width = w
      m.height = h
      #puts m.inspect
      #puts "------------------------------"
      m.save

      `chmod -R 1777 #{new_image_jpg}`
      `chmod -R 1777 #{small_jpg_152_file}`
      `chmod -R 1777 #{new_image_png}`
      `rm #{local_path}#{local_name}`

     rescue => e
       p e.to_s
     end
  end
end
