# -*- encoding : utf-8 -*-
class DapeiTag < ActiveRecord::Base
  acts_as_api
  api_accessible :public,  :cache => 300.minutes do |t|
    t.add :id
    t.add :name
    t.add :desc
    t.add :get_img_url, :as => :img_url
    t.add lambda{|tag| tag.img_url }, :as => :bottom_img_url
    t.add :tag_type
    t.add :weight
    t.add :is_hot
    t.add lambda{|tag| tag.get_date }, :as => :date
    t.add lambda{|tag| DapeiTag.sub(tag.id) }, :as => :sub_tags
  end

  def to_json
    {
     :id => self.id.to_s,
     :name => self.name,
     :desc => self.desc,
     :img_url => self.get_img_url,
     :bottom_img_url => self.img_url,
     :date => self.get_date_detail,
     :user => self.get_user_json,
     :share => self.share_dict
    }
  end

  def share_dict
    {
      :url => "http://m.shangjieba.com/dapeis/theme_view/#{self.id}",
      :img => self.get_img_url,
      :title => self.name.to_s[0, 200],
      :desc => self.desc.to_s[0, 200]
    }
  end


  scope :sub, lambda { |cid|
    where( :parent_id => cid  ).where(:is_hot => true).order("weight desc")
  }

  def get_date
    self.created_at.strftime("%m月%d日") if self.created_at 
  end

  def get_date_detail
    self.created_at.strftime("%y.%m.%d") if  self.created_at
  end

  def get_user
    if self.user_id
      User.find self.user_id
    end
  end

  def get_user_json
    if self.get_user
     self.get_user.to_dict
    else
     {}
    end
  end

  def self.get_banner
    DapeiTag.find_by_id(99)
  end

  def self.get_parent_tags
    tags = []
    tags << ["无", 0]
    DapeiTag.where( "parent_id is null or parent_id=0" ).each do |t|
      if t
        tags << [t.name, t.id]
      end
    end
    tags
  end

  def get_img_url_old
    self.get_img_url + '?imageView2/1/w/640/h/280'
  end

  def get_img_url
    if self.avatar_url
      return self.avatar_url.gsub("http://www.shangjieba.com",  AppConfig[:remote_image_domain]).gsub("http://img.shangjieba.com", AppConfig[:remote_image_domain])
    elsif self.image_thing and self.image_thing != ""
      return  AppConfig[:remote_image_domain] + "/uploads/cgi/img-thing/size/s/tid/#{self.image_thing}.jpg"
    else
      return  AppConfig[:remote_image_domain] + "/uploads/cgi/img-thing/size/s/tid/2013092106.jpg"
    end
  end

end
