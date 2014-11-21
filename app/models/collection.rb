# -*- encoding : utf-8 -*-
class Collection < Item
  # has_many :relations ,:primary_key => 'item_id'
  has_many :skus, :through => :relations, :source => :target, :source_type => "Sku"

  def dapei_info
    DapeiInfo.find_by_dapei_id(self.id)
  end

  def get_skus
    self.skus
    # skus = []
    # relations = Relation.where(:item_id => self.id).order('created_at DESC')
    # relations.each do |r|
    #   if r.target_type=Sku
    #     sku  = Sku.find_by_id( r.target_id )
    #     skus << sku
    #   end
    # end
    # skus
  end


  def get_items(page=1, limit=12)
    items = []
    relations = Relation.where(:item_id => self.id).paginate(:page => page, :per_page => limit)
    relations.each do |r|
      if r.target_type=Sku
        sku = Sku.find_by_id(r.target_id)
        items << sku.wrap_item if sku and not sku.deleted
      end
    end
    items
  end

  def get_first_sku
    # rel = Relation.where(:item_id => self.id).limit(1)[0]
    # return Sku.find_by_id( rel.target_id )
    self.relation.target if self.relation.target.is_a? ::Sku
  end


  def get_items_count
    Relation.where(:item_id => self.id).count
    #self.get_items.length
  end

  def get_domain
    #domain
    AppConfig[:remote_image_domain]
  end

  def get_dpimg_urls
    imgs = []
    if self.category_id == 1000
      temp = {}
      temp[:img_url] = "http://img.shangjieba.com/assets/img.jpg"
      temp[:width] = 600
      temp[:height] = 600
      if self.photos.length > 0
        photo = self.photos.first
        temp[:img_url] = self.img_url(nil)
        temp[:width] = photo.width
        temp[:height] = photo.height
      elsif self.get_items_count > 0
        #sku = self.get_items[0]
        sku = self.get_first_sku
        p = sku.first_photo
        temp[:img_url] = p.url
        temp[:width] = p.width
        temp[:height] = p.height
      end
      imgs << temp
    end
    imgs
  end

  # def img_url(size)
  #   # if self.photos.length > 0
  #   #   self.img_url(size)
  #   # elsif self.get_items_count > 0
  #   #   if self.get_first_sku
  #   #     self.get_first_sku.img_url(size)
  #   #   else
  #   #     ""
  #   #   end
  #   # end
  # end

  # 有转化的封面图
  def cover_img_url(size = "normal_small")

    if self.photos.present?
      "#{AppConfig[:remote_image_domain]}#{self.photos.first.processed_image.url}#{PHOTO_SIZE[size]}"
    end

    # self.get_domain
    # if self.base_url && File.exist?(self.cover_photo_path)
    #   p_size = ::PHOTO_SIZE[size]
    #   self.get_domain + "/uploads/images/cover/#{self.base_url}/cover_#{self.id}.jpg#{p_size}"
    # end
  end


  def cover_photo_path
    if self.base_url
      Rails.root.join('public', 'uploads', 'images', 'cover', self.base_url, "cover_#{self.id}.jpg")
    end
  end

  def dapei_img_url(size = "normal_small")

    cover_img_url(size) || self.get_first_sku.img_url(nil)
    # if self.photos.length > 0
    #   self.img_url(nil)
    # elsif self.get_items_count > 0
    #   self.get_first_sku.img_url(nil)
    # end
  end

  alias img_url dapei_img_url

  def get_dpimg_urls1(small=false)
    imgs = []
    if true
      temp = {}
      if self.dapei_info
        unless small
          temp[:img_url] = get_domain + "/uploads/cgi/img-set/cid/#{self.id}/id/#{self.dapei_info.spec_uuid}/size/y.jpg"
        else
          temp[:img_url] = get_domain + "/uploads/cgi/img-set/cid/#{self.id}/id/#{self.dapei_info.spec_uuid}/size/m.jpg"
        end
      else
        temp[:img_url] = "http://img.shangjieba.com/assets/img.jpg"
      end
      unless small
        temp[:width] = 600
        temp[:height] = 600
      else
        temp[:width] = 150
        temp[:height] = 150
      end
      imgs << temp
    end

    imgs
  end


  def img_url1(dpi ='y')
    size = "y"
    size = "m" if dpi == "m"
    unless (dpi = self.dapei_info).blank?
      self.get_domain + "/uploads/cgi/img-set/cid/#{dpi.dapei_id}/id/#{dpi.spec_uuid}/size/#{size}.jpg"
    else
      ""
    end
  end

  def dapei_img_url1
    self.get_domain + "/uploads/cgi/img-set/cid/#{self.id}/id/#{self.dapei_info.spec_uuid}/size/m.jpg"
  end


  def user_name
    if self.get_user
      self.get_user.name.to_s
    else
      ""
    end
  end

  def user_url
    if self.get_user
      self.get_user.url
    else
      ""
    end
  end

  def user_img_small
    if self.get_user
      self.get_user.display_img_small
    else
      ""
    end
  end


  # 生成首图 四张 150x150的图片合并
  def cover_photo(skus)
    agent = ::Mechanize.new
    # 生成图片
    skus.each do |sku|
      agent.get(sku.img_url(1) + '?imageView/2/w/300/h/300').save("images/cover/#{sku.id}.jpg")
    end
    image1 = Rails.root.join('images', 'cover', "#{skus[0].id}.jpg")
    image2 = Rails.root.join('images', 'cover', "#{skus[1].id}.jpg")
    hor_img = Rails.root.join('images', 'cover', "#{skus[0].id}_#{skus[1].id}.jpg")
    image3 = Rails.root.join('images', 'cover', "#{skus[2].id}.jpg")
    image4 = Rails.root.join('images', 'cover', "#{skus[3].id}.jpg")
    ver_img = Rails.root.join('images', 'cover', "#{skus[2].id}_#{skus[3].id}.jpg")
    base_url = Date.current.to_s
    path = Rails.root.join('public', 'uploads', 'images', 'cover', base_url)
    FileUtils.mkdir_p path
    result_img = path.join("cover_#{self.id}.jpg")
    `convert +append #{image1} #{image2} #{hor_img}`
    `convert +append #{image3} #{image4} #{ver_img}`
    `convert -append #{hor_img} #{ver_img} #{result_img}`
    photo = self.photos.build
    photo.author = self.user
    photo.processed_image = File.open(result_img)
    photo.save!
    FileUtils.rm([image1, image2, image3, image4, hor_img, ver_img,result_img])
  end


end
