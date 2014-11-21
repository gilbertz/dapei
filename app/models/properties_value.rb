# -*- encoding : utf-8 -*-
class PropertiesValue < ActiveRecord::Base

  belongs_to :properties
  belongs_to :line_item
  has_many :property_property_values

end
