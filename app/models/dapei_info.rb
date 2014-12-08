# -*- encoding : utf-8 -*-
class DapeiInfo < ActiveRecord::Base
  acts_as_taggable

  belongs_to :dapei
  belongs_to :category
  belongs_to :user

  has_many :dapei_item_infos

  attr_accessible :did, :basedon_tid, :title, :description, :comment, :tags, :tagged, :by, :category_id, :post_share, :user_id, :dapei_id, :spec_uuid, :is_show, :color_one_id, :color_two_id, :color_three_id, :start_date, :end_date, :start_date_hour,  :is_star, :original_id

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

  def get_matters(page=1, limit=12)
    dis = self.dapei_item_infos.page(page).per(limit)
    matters = []
    dis.each do |i|
      matters << i.get_matter
    end
    matters
  end

  def get_dapei_items(page=1, limit=12)
    self.get_matters
  end

  
  def get_domain
      AppConfig[:remote_image_domain]
  end 

 
  def img_url(size)
      self.get_domain + "/uploads//cgi/img-set/id/#{self.spec_uuid}/size/s.jpg"
  end

end
