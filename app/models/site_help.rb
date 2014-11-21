# -*- encoding : utf-8 -*-
class SiteHelp < ActiveRecord::Base

  has_many :photos, :as => :target, :dependent=>:destroy
  class << self
    def create_help
  	  if first.blank?
  	  	abouts = About.all[0..2]
  	  	abouts.each do |about|
  	  	  p_s = create({parent_id:0,name:about.name})
  	  	  about.childs.each do |child|
  	  	  	c_s = create({parent_id:p_s.id,name:child.name,url:child.url,url_action:child.action})
  	  	  	p c_s
  	  	  end
  	  	end
  	  end
    end    

  end

  def name
  	if parent_id == 0
  	  super
  	else
      "|---" + super
  	end
  end

  def content
  	c = super
  	if c.blank? and parent_id != 0
      '<div style="font-size:20px;text-align;margin:40px">准备中...</div>'
    else
      c
  	end
  end

end
