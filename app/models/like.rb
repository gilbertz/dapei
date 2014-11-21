# -*- encoding : utf-8 -*-
#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Like <  ActiveRecord::Base
  #include Sjb::Likeable

  belongs_to :user, :counter_cache=>true
  
  after_create do
    self.parent.update_likes_counter
    self.parent.touch
    #self.parent.incr_dispose
    send_notifications
  end

  after_create :check_user_like_count

  after_destroy do
    self.parent.update_likes_counter
    self.parent.touch
  end

  def parent
    return (self.target_type.constantize).find(self.target_id)
  end
  
  def target
  end

  def self.has_liked?(user_id, target_id, target_type)
    if Like.find_by_user_id_and_target_id_and_target_type(user_id, target_id, target_type.to_s)
      return true
    else
      return false
    end
  end

  # NOTE API V1 to be extracted
  acts_as_api
  api_accessible :public, :cache => 60.minutes do |t|
    #t.add :id
    t.add lambda{|like| like.id.to_s}, :as => :id
    t.add :target_type, :as=>:liked_type
    t.add :liked_id_s, :as=>:liked_id
    t.add :liker_url, :as=>:liker_id
    t.add :created_at
    t.add :user_name
    t.add :user_url
    t.add :user_img_small
  end

  api_accessible :error do |t|
    t.add :errors
  end

  def check_user_like_count

    begin_at = Time.now.strftime("%Y-%m-%d 03:30:00")
    end_at = Time.now.strftime("%Y-%m-%d 05:00:00")

    like_count = Like.where("created_at >= '#{begin_at}' and created_at <= '#{end_at}' and target_type = 'Item' and user_id = #{self.user_id}").count

    if like_count >= 38
      lcu = LikeCountUser.new(:user_id => self.user_id)
      lcu.save
    end

  end

  def liker_url
    User.find(self.user_id).url
  end

  def liked_id
    if target_type=="Item" or target_type=="Shop" or target_type=="Brand"
      target_type.constantize.find(self.target_id).url
    else
      self.target_id
    end
  end  

  def liked_id_s
    if target_type=="Item" or target_type=="Shop" or target_type=="Brand"
      target_type.constantize.find(self.target_id).url
    else
      self.target_id.to_s
    end
  end

  def user_name
    if self.user
      self.user.name.to_s
    else
      ""
    end
  end

  def user_url
    if self.user
      self.user.url
    else
      ""
    end
  end

  def user_img_small
    if self.user
      self.user.display_img_small
    else
      ""
    end
  end

  
  def self.like_users(target, page, limit)
    cond = "1=1"
    like_users = []
    if User.current_user
      cond = "likes.user_id  != #{User.current_user.id}"
      if target.like_id.to_i > 0 and page.to_i == 1
        like_users << User.current_user
        limit -= 1 
      end 
    end
    likes = target.likes.where( cond ).order('created_at DESC').page(page).per(limit)
    like_users += likes.map(&:user)
    like_users
  end

  def self.like_users_have_repeat(target, page, limit, user_id)
    cond = "1=1"
    like_users = []
    #if User.current_user and page.to_i == 1
    #  cond = ""
    #  if target.like_id.to_i > 0
    #    like_users << User.current_user
    #  end
    #end
    likes = target.likes.includes(:user => [:photos]).where( cond ).order('created_at DESC').page(page).per(limit)
    like_users += likes.map(&:user)

    if like_users.length >= 2
      for user in like_users do
        if user.id == user_id.to_i
          like_users = like_users.delete(user)
          unless like_users.instance_of?(User)
            like_users = like_users.reverse.append(user).reverse
          else
            like_users = [user]
          end
          break
        end
      end
    end
    like_users
    
  end


  def notification_type(user, person)
    #TODO(dan) need to have a notification for likes on comments, until then, return nil
    return nil if self.target_type == "Comment"
  end


  def send_notifications
    target = self.target_type.constantize
    target_uid = 0
    if (target_type=="Item" or target_type=="Dapei") and self.user.is_real
      target_uid = target.find_by_id(self.target_id).user_id
      unless target_uid == self.user_id
        user=User.find(target_uid)
        user.notify("A new like", "Youre not supposed to see this", self)
        user.set_notify_status
        user.didi
        #user.query_notify
      end
    end

    if (target_type=="DapeiResponse")
      dp = DapeiResponse.find_by_id( self.target_id )
      target_uid = dp.user_id
      unless target_uid == self.user_id
        PushNotification.push_dapei_comm_notify(target_uid, dp.request_id, '有人赞了你的搭配问问回答') 
      end 
    end 


  end

  def self.cache_likes_users_count_by_target(sku)
    Rails.cache.fetch "#{sku.class.to_s}/#{sku.id}/likes/count/updated/#{sku.updated_at.to_i}", :expires_in => 3.minutes do
      sku.likes.count
    end
  end

  def self.cache_likes_users_by_target(sku, page, limit, user_id)
    Rails.cache.fetch "#{sku.class.to_s}/#{sku.id}/likes/user_id/#{user_id}/updated/#{sku.updated_at.to_i}", :expires_in => 3.minutes do
      #Like.like_users_have_repeat(sku, page, limit, user_id)
      Like.like_users(sku, page, limit)
    end
  end

end
