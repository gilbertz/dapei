# -*- encoding : utf-8 -*-
class PropertyPropertyValue < ActiveRecord::Base

  attr_accessible :line_item_id, :property_id, :property_value_id

  #下单选择的属性值

  belongs_to :property
  belongs_to :sku_property, :foreign_key => "property_value_id"


end
