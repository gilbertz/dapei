# -*- encoding : utf-8 -*-
class MainColor < ActiveRecord::Base

  before_save :update_color

  def color_with_sharp
    "#" << color_value
  end

  private
  def update_color
    self.color_r = (color_value[0..1]).hex
    self.color_g = (color_value[2..3]).hex
    self.color_b = (color_value[4..5]).hex
  end


end
