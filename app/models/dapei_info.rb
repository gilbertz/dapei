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

  def get_skus(page=1, limit=12)
    skus = []
    dis = self.dapei_item_infos.page(page).per(limit)
    sku_ids = []
    dis.each do |i|
      if i.sku and not i.sku.deleted
        unless sku_ids.include?(i.sku.id)
          skus << i.sku
          sku_ids << i.sku.id
        end
      end
    end
    skus
  end

  def get_dapei_items(page=1, limit=12)
    items = self.get_skus(page, limit).map{ |s|s.wrap_item }
    
    #sku_ids = []
    #searcher = Searcher.new(city_id, "item", nil,  "near", limit = 20, page= "1", nil, nil, lng, lat, nil, sku_ids)
    #items = searcher.search()
    #item_ids = []
    #if items
    #  items.each do |id|
    #    item_ids << id 
    #  end
    #end

    #skus.each do |sku|
    #  items << sku.wrap_item unless sku_ids.include?(sku.id)
    #  sku_ids << sku.id
    #end

    items
    #self.sku.wrap_item
  end

  
  def get_domain
      AppConfig[:remote_image_domain]
  end 

 
  def img_url(size)
      self.get_domain + "/uploads//cgi/img-set/id/#{self.spec_uuid}/size/s.jpg"
  end

end
