# -*- encoding : utf-8 -*-
class ShipAddress < ActiveRecord::Base



  attr_accessible :name, :user_id, :area, :address, :phone, :is_default, :postcode

end
