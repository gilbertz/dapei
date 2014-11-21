# -*- encoding : utf-8 -*-
class DarenApply < ActiveRecord::Base


  belongs_to :user

  acts_as_api
  api_accessible :public, :cache => 60.minutes do |t|
    t.add :qq
    t.add :mobile
    t.add :reason
    t.add :created_at
    t.add lambda{|da| da.status.to_i.to_s}, :as => :status
    t.add :get_imgs, :as => :imgs
    t.add :get_user, :as => :user
  end

  def get_user
    User.find_by_id(self.user_id)
  end

  def get_status
    unless self.get_user.blank?
      self.get_user.get_daren_status
    else
      0
    end
  end

  def get_imgs
      imgs = []
      [ self.photo1_id, self.photo2_id, self.photo3_id].each do |pid|
        next unless pid
        photo = Photo.find_by_id( pid )
        imgs << photo.url(nil) if photo
      end
      imgs 
  end


  def self.default_head_img
      "http://www.shangjieba.com/assets/tou.png"
  end



end
