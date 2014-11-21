# -*- encoding : utf-8 -*-
class Mall < ActiveRecord::Base
  has_many :shops
  has_many :photos, :as => :target#, :dependent=>:destroy
  has_many :discounts, :as => :discountable, :dependent=>:destroy
  has_many :crawler_templates

  acts_as_url :name#, :sync_url=>true

  def avatar
    if self.avatar_id
      Photo.find_by_id(self.avatar_id)
    end
  end
  
  def profile_image
      if self.avatar
          self.avatar.url
      else
          "/assets/0.gif"
      end
  end

  def shop_avatar_url
    self.profile_image
  end

  def get_current_discount
    discount=nil
    unless self.discounts.blank?
      self.discounts.sort_by{|discount| discount.updated_at}
      discount=self.discounts.last
    end
    if not discount.deleted
      discount
    end
  end

  
  def get_last_discount
    unless self.discounts.blank?
      self.discounts.sort_by{|discount| discount.updated_at}
      self.discounts.last
    end
  end

  def mall_shop
    self.shops.where(:shop_type => 11).last
  end

  def get_shops_count
    self.shops.count - 1
  end
  
end
