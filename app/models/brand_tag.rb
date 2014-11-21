# -*- encoding : utf-8 -*-
class BrandTag < ActiveRecord::Base
  def self.get_tags( type_id )
     tags = []
     tags <<['无', 0]
     BrandTag.where( :type_id => type_id ).each do |tag|
       tags << [tag.name, tag.id]
     end
     tags
  end
end
