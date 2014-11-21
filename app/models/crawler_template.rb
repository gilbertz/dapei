# -*- encoding : utf-8 -*-
class CrawlerTemplate < ActiveRecord::Base
  belongs_to :brand
  belongs_to :mall

  def get_brand_name
    if self.brand
      self.brand.name
    else
      ""
    end
  end

  def get_mall_name
    if self.mall
      self.mall.name
    else
      ""
    end
  end

  def sync_mall_shop
    if self.mall
      s = self.mall.mall_shop
      p s
      s.weibo = self.source if s
      s.save if s
    end
  end
  

end
