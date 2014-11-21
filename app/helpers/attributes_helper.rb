# -*- encoding : utf-8 -*-
module AttributesHelper
  def line_item_attributes
    [:id,:image,:sku_id,:quantity,:name,:created_at,:brand_id, :price]
  end

  def product_attributes
    [:id,:name,:description]
  end

  def variant_attributes
    [:id,:name,:sku,:price,:weight,:height,:width,:depth,:is_master,:price]
  end

  def items_attributes
    [:id,:image,:quantity,:price]
  end

  def order_attributes
    [:id,:number,:user_id,:state,:item_total,:total,:created_at, :mark]
  end

  def default_address_attributes
    [:id,:user_id,:name,:address,:phone,:area]
  end
  alias ship_address_attributes default_address_attributes

  def user_attributes
    [:id,:mobile,:name,:token]
  end
end
