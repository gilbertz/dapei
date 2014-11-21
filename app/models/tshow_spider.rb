# -*- encoding : utf-8 -*-
class TshowSpider < ActiveRecord::Base
  attr_accessible :author, :brand_id, :city, :content, :images_start_page, :is_template, :season, :show_date, :start_page, :stop,\
  :template_id, :show_page, :img_attr, :img_rule, :others
  belongs_to :brand
  has_many   :tshows, :dependent=>:destroy

  def template_spider
    if self.template_id && self.template_id > 0
      self.class.find(template_id)
    else
      self
    end
  end

end
