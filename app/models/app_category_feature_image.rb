# -*- encoding : utf-8 -*-
class AppCategoryFeatureImage < ActiveRecord::Base

  def self.get_fi(category_id, main_color_id)
    a = AppCategoryFeatureImage.where({:category_id => category_id, :main_color_id => main_color_id}).first
    if a.blank?
      a = AppCategoryFeatureImage.new
    end
    a
  end

end
