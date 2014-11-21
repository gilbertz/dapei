# -*- encoding : utf-8 -*-
class LineItem < ActiveRecord::Base

  STATUS = {
      '未选中' => 0,
      '已选中' => 1,
      '已下架' => 2,
      '订单中' => 3
  }

  attr_accessible :cart_id, :order_id, :name, :sku_id, :quantity, :image, :price, :brand_id

  attr_accessor :get_size_property_value, :get_color_property_value

  belongs_to :cart
  belongs_to :order
  belongs_to :sku
  has_many :properties_values
  belongs_to :brand

  # state 0 购物车   2 已下线    3 已下单


  def brand_name
    unless self.sku.brand.blank?
      self.sku.brand.name
    else
      ""
    end
  end

  def sub_total
    self.quantity * self.price
  end

  #获取选择的尺码属性
  def get_size_property
    PropertyPropertyValue.where(:property_id => 1, :line_item_id => self.id).first
  end

  #获取选择的颜色属性
  def get_color_property
    PropertyPropertyValue.where(:property_id => 2, :line_item_id => self.id).first
  end

  def get_size_property_value
    unless self.get_size_property.blank?
      self.get_size_property.sku_property.try(:value)
    else
      ""
    end
  end

  def get_color_property_value
    unless self.get_color_property.blank?
      self.get_color_property.sku_property.try(:value)
    else
      ""
    end
  end

  def self.update_state(items)
      items.each do|i|
        if i.sku.online?
          i.update_attribute(:state, 1)
        else
          i.update_attribute(:state, 2)
        end
      end
  end


end
