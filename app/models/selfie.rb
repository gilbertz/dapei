# encoding: utf-8
# 自拍
class Selfie < Item
  # acts_as_taggable_on :brand, :price, :theme
  acts_as_tagger

  mount_uploader :cover_image, MetaImageUploader


  # 重写 title , 句号分隔,前面部分是title,后面部分是描述
  def set_title_and_desc(title)
    regex = /([.|,|，|;|!|！|。|．|。])+?/
    index = regex=~title
    if index 
      self.title = title.slice!0,index
      self.desc = title.slice!1,title.size
    else
      self.title ="爱make,爱生活"
      self.desc = title
    end
    self.save

    # title.match(/([.|,|，|;|!|！|。|．|。])+?/)
    # if $1.present?
    #   self.title, self.desc = title.split($1)
    # else
    #   self.title = '爱make,爱生活'
    #   self.desc = title
    # end
  end

  # 创建一个自拍,最多有3张照片,每张照片有N多tags,tagging 要对应 tag_info ,热门标签(无标签信息)
  # data = {"selfie":{"imageInfo":[{"heght":"1080", "img":"", "imgType":"jpg", "tag":[], "width":"1080"}], "tag_str":["tag_str1", "tag_str2"], "title":"公司"}}
  def api_publish(data)
    raise '空参数!' if data["selfie"].blank?
    selfie = data["selfie"]

    # self.title = selfie["describe"] # 自拍的标题
    # self.desc = selfie['describe']
    self.category_id = 1002
    self.set_title_and_desc(selfie["describe"])
    self.tag_list.add(selfie["tag_str"]) # 自拍的标签，所有的，用于自拍
    self.ctag_list.add(selfie["tag_str"]) #风格标签
    self.ctag_list.each do |ctag|
      self.user.set_ctag(ctag)
    end
    Selfie.transaction do
      # 上传图片,最多3张
      selfie['imageInfo'].each do |img|
        photo = self.photos.build
        photo.author = self.user
        img_path = base64_cover_file(img['img'], img['imgType'])
        photo.processed_image = File.open(img_path)
        photo.width = img['width']
        photo.height = img['height']
        FileUtils.rm(img_path)
        # 每张图片上打标签
        self.save!
        img['tag'].each do |tag|
          case tag['type'].to_s
            when "0" # 品牌
              self.user.set_brand_tag(tag["name"])
              self.tag(photo, :with => tag["name"], :on => :brand)
              self.btag_list.add(tag["name"])
              self.tag_list.add(tag["name"])
              photo.add_tag_info(tag, "brand")
            when "1" # 价格
              self.tag(photo, :with => tag["name"], :on => :price)
              photo.add_tag_info(tag, "price")
          end
        end
        self.save!
      end
      # 生成水印图
       self.make_share_img # 上线用
    end
    self.save
    self.index_info = self.tag_list.join(",")
    if self.photos.size == 0
      self.dapei_info_flag = 1
    end
    self.show_date = self.created_at
    self.rand_like
    self.save
  end

  def get_items
    []
  end

  # app 首页图
  def selfie_small_picture
    if self.photos.first
      selfie_image_path = Photo::Sjb_root.to_s + "/public" + self.photos.first.processed_image.thumb_150.url
      if FileTest::exist? selfie_image_path
        AppConfig[:remote_image_domain] + self.photos.first.processed_image.thumb_150.url
      else
        AppConfig[:remote_image_domain] + self.photos.first.processed_image.url
      end
    end
  end

  # app 首页图
  def dapei_img_url
    if self.photos.first
        AppConfig[:remote_image_domain] + self.photos.first.processed_image.url
    end
  end

  def img_url(name=nil)
    self.dapei_img_url
  end

  # # 自拍 图片数据
  # def get_dpimg_urls
  #   photos = []
  #   if self.photos.present?
  #     photo = self.photos.first
  #     photo_hash = {:img_url => "#{AppConfig[:remote_image_domain]}#{photo.processed_image.url}", :width => photo.width, :height => photo.height}
  #     tags = []
  #     photo.tag_infos.each do |tag_info|
  #       tags << {:type => tag_info.tag_type, :point_x => tag_info.point_x,
  #                :point_y => tag_info.point_y, :direction => tag_info.direction ? 1 : 0, :name => tag_info.name
  #       }
  #     end
  #     photo_hash[:tags] = tags
  #     photos << photo_hash
  #   end
  #   photos
  # end

  # 自拍 图片数据
  def get_dpimg_urls
    temp={:img_url =>"http://qingchao2.qiniudn.com/1251008728/zjl/baotu.jpg", :width => "300", :height => "300"}
    photos = []
    if self.photos.present?
      # photo = self.photos.order(created_at:desc)
      photo = self.photos
      photo.each do |photo|
        photo_hash = {:img_url => "#{AppConfig[:remote_image_domain]}#{photo.processed_image.url}", :width => photo.width, :height => photo.height}
        tags = []
        photo.tag_infos.each do |tag_info|
          tags << {:type => tag_info.tag_type, :point_x => tag_info.point_x,
                   :point_y => tag_info.point_y, :direction => tag_info.direction ? 1 : 0, :name => tag_info.name
          }
        end
        photo_hash[:tags] = tags
        photos << photo_hash
      end
    end
    if photos.blank?
      photos<<temp
    end
    photos
  end

  # 生成水印图
  def make_share_img
    photo = self.photos.first
    # photo_url = photo.processed_image.url #正式用地址
    photo_url = "http://qingchao1.qiniudn.com/uploads/cgi/img-set/cid/20140929/5516409/id/8eXKekjAkdjtUWQE0LPy/size/y.jpg"
    makewatch_img = Utils.urlsafe_base64_encode 'http://shangjieba.com/uploads/shuiyin2.png'
    makewathc_url = "#{photo_url}?watermark/1/image/#{makewatch_img}/dissolve/50/gravity/SouthEast/dx/20/dy/20"
    agent = Mechanize.new
    path = Rails.root.join('public', 'uploads', 'images', 'makewatch', self.id.to_s)
    file_name = path.join('makewatch.jpg')
    FileUtils.mkdir_p(path)
    agent.get(makewathc_url).save(file_name)
  end

  def share_img1
    path = ("/uploads/images/makewatch/#{self.id.to_s}/makewatch.jpg")
    AppConfig[:remote_image_domain] + path
  end


  private

  def base64_cover_file(base64_code, img_type ='jpg')
    path = Rails.root.join("tmp", "#{Digest::MD5.hexdigest(SecureRandom.random_number.to_s)}.#{img_type}")
    File.open(path, 'wb') do |f|
      f.write(Base64.decode64(base64_code))
    end
    path
  end


  # # 传入base64的编码上传图片
  # def create_photo(base64_code)
  #   File.open(image_path, 'wb') do|f|
  #     f.write(Base64.decode64(base64_code))
  #   end
  # end
  #
  #
  # def image_path
  #   base_url = Date.current.to_s
  #   file_name = "#{self.id}.jpg"
  #   path = Rails.root.join("public", 'uploads', 'images', 'selfie', base_url)
  #   FileUtils.mkdir_p path
  #   path.join file_name
  # end

end
