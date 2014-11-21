# -*- encoding : utf-8 -*-
class SkuProperty < ActiveRecord::Base

  belongs_to :sku
  belongs_to :property


  def value
    unless self[:value].blank?
      self[:value]
    else
      "默认"
    end
  end

  def color_image_url
    unless self[:color_image_url].blank?
      self[:color_image_url]
    else
      "默认"
    end
  end

end
