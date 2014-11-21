# -*- encoding : utf-8 -*-
class Street < ActiveRecord::Base
  has_many :shops
  has_many :photos, :as => :target#, :dependent=>:destroy

  acts_as_url :name#, :sync_url=>true

  def avatar
    if self.avatar_id
      Photo.find_by_id(self.avatar_id)
    end
  end

  scope :recommended, lambda { |city_id|
    joins("INNER JOIN recommends ON recommends.recommended_id = streets.id").where("streets.city_id=#{city_id}").where('recommends.recommended_type' => "Street").order("created_at desc").limit(10)
  }
 

end
