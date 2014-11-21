# -*- encoding : utf-8 -*-
class Tshow < ActiveRecord::Base
  attr_accessible :author, :brand_id, :city, :content, :season, :show_date, :tshow_spider_id, :docid, :url, :photos
  belongs_to :brand
  belongs_to :tshow_spider
  has_many :photos, :as => :target
end
