# -*- encoding : utf-8 -*-
class Property < ActiveRecord::Base

  #所有属性

  attr_accessible :name

  has_many :property_property_values


end
