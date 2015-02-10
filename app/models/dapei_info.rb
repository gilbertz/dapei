# -*- encoding : utf-8 -*-
class DapeiInfo < ActiveRecord::Base
  acts_as_taggable

  belongs_to :dapei
  belongs_to :category
  belongs_to :user

  has_many :dapei_item_infos
  has_many :tag_infos, :as => :dapei

  attr_accessible :did, :basedon_tid, :title, :description, :comment, :checksum, :tags, :tagged, :by, :category_id, :post_share, :user_id, :dapei_id, :spec_uuid, :is_show, :color_one_id, :color_two_id, :color_three_id, :start_date, :end_date, :start_date_hour,  :is_star, :original_id

  
  def add_brand_tag(matter, x, y)
    unless tag_info = TagInfo.find_by_dapei_id_and_matter_id(self.id, matter)
      tag_info = TagInfo.new
    end
    tag_info.name = matter.brand_name
    tag_info.dapei_id = self.id
    tag_info.matter_id = matter.id 
    tag_info.tag_type = 'brand'
    tag_info.coord = "#{x}_#{y}"
    tag_info.direction = '0'
    tag_info.save!
  end

  def get_tag_infos
    TagInfo.where(:dapei_id =>  self.id)
  end

  def get_ratio
    sz = self.width.to_i
    sz  = self.height.to_i if self.height.to_i > self.width.to_i
    if sz > 0 and sz < 960 
      960.0/sz
    else
      1.0 
    end
  end

  def get_template
    if self.original_id
      di = DapeiInfo.find_by_id(self.original_id)
      Dapei.find_by_id(di.dapei_id) if di
    end
  end

  def get_matters
    dis = self.dapei_item_infos
    matters = []
    dis.each do |i|
      matters << i.get_matter
    end
    matters.uniq
  end

  def get_items
    dis = self.dapei_item_infos
    items = []
    dis.each do |i|
      m = i.get_matter
      items << m if m.brand_id or m.user_id
    end
    items.uniq
  end

  
  def get_domain
      AppConfig[:remote_image_domain]
  end 

 
  def img_url(size)
      self.get_domain + "/uploads//cgi/img-set/id/#{self.spec_uuid}/size/s.jpg"
  end

end
