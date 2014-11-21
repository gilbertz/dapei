# -*- encoding : utf-8 -*-
class Comment < ActiveRecord::Base
  include Sjb::Likeable
  include ActsAsCommentable::Comment

  belongs_to :commentable, :polymorphic => true, :counter_cache=>true, :touch =>true

  belongs_to :user, :counter_cache=>true

  #default_scope :order => 'created_at DESC'

  after_create :send_notifications

  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_voteable

  # NOTE: Comments belong to a user
  belongs_to :user

  acts_as_api
  api_accessible :public, :cache => 60.minutes do |t|
    #t.add :id
    t.add lambda{|comment| comment.id.to_s}, :as => :id
    t.add :user_url, :as=>:user_id
    t.add :user_name
    t.add :user_img_small
    t.add :comment
    t.add :commentable_type
    t.add :comm_url, :as=>:commentable_id
    t.add :created_at
    t.add :updated_at
    t.add :created_time
    t.add :get_user, :as => :user, :template => :light
    t.add :get_to_user, :as => :to_user, :template => :light
  end

  api_accessible :error do |t|
    t.add :errors
  end

  def get_user
    self.user
  end

  def get_to_user
    if self.tuid
      tu = User.find_by_id(self.tuid)
      tu
    end
  end

  def comm_url
    if (self.commentable_type=="Post")
      url=self.commentable_id
    elsif(self.commentable_type=="Item")
      item = Item.find_by_id(self.commentable_id)
      url = item.url if item
    elsif(self.commentable_type=="Shop")
      shop = Shop.find_by_id(self.commentable_id)
      url = shop.url if shop
    end
    url.to_s
  end

  def user_url
    if self.user
      self.user.url
    else
      ""
    end
  end

  def user_name
    if self.user
      self.user.display_name
    else
      ""
    end
  end

  def user_img_small
    if self.user
      self.user.display_img_small
    else
      "http://www.shangjieba.com/assets/img.jpg"
    end
  end

  def created_time
    self.created_at.localtime.strftime("%F %H:%M")
  end

  def updated_time
    self.updated_at.localtime.strftime("%F %H:%M")
  end

  def created_utc_time
    self.created_at.to_s
  end

  def self.deal_ad(comment)
    words = ['tao宝', '网上工作', '淘宝','天猫','夭猫', '微信','日赚','加企鹅','qq', '找工作', '兼职', '扣扣', '加扣', '加q', '+q', 'weixin', '结清']
    comment_txts = ['cool!', '好看！', '我要', '顶', '好棒！', '牛！', '哪里可以买！', '赞一个', '沙发', '路过']
    ad = false
    words.each do |w|
      txt = comment.comment.to_s
      txt = txt.downcase
      next if comment.get_user.get_level >= 2
      next if comment.get_user.id < 30000 
      if txt.downcase.index(w) or comment.get_user.get_level < 0
        idx = comment.id % comment_txts.length
        comment.comment =  comment_txts[idx]
        comment.get_user.level = -1
        comment.get_user.save
        break
      end
    end
    comment
  end

  def self.dup(comments)
    cs = []
    comments.each do |c|
      cs << deal_ad(c)
    end
    cs
  end

  def send_notifications
    if commentable_type == "Item" or commentable_type == "Dapei"
      commentable=commentable_type.constantize.find(commentable_id)
      #commenters=commentable.comments.collect {|c| c.user_id }

      #p commentable
      if commentable_type == "Item" and commentable.category_id == 1001
        user_id = commentable.user_id
        dapei_id = commentable.url
        #msg = self.comment
        msg = "你的搭配收到" + self.user_name + "的评论"
        #p "PushNotification.push_dapei_msg(#{user_id}, #{dapei_id}, #{msg})"
        if user_id != commentable.user_id
          PushNotification.push_dapei_msg(user_id, dapei_id, msg)
        end
      end

      commenters = []
      commenters << commentable.user_id
      commenters << self.tuid if self.tuid
      commenters.uniq.each do |c|
        unless c==self.user_id
          if c
            user=User.find(c)
            if user
              user.notify("A new comment", "Youre not supposed to see this", self)
              #user.set_notify_status
              #user.query_notify
              user.didi
            end
          end
        end
      end
    end

    if ( commentable_type == "DapeiResponse")
      commentable = commentable_type.constantize.find(commentable_id)
      target_uid = commentable.user_id
      unless target_uid == self.user_id
        PushNotification.push_dapei_comm_notify(target_uid, commentable.request_id, '有人评论了你的搭配问问回答')
      end 
    end 

  end


  def self.cache_comments_by_target(sku, page, limit)
    Rails.cache.fetch "#{sku.class.to_s}_#{sku.id}_#{page}_#{sku.updated_at.to_i}", :expires_in => 10.minutes do
      sku.comments.order("comments.created_at asc").page(page).per(limit).entries
    end
  end

  def self.cache_comments_count_by_target(sku)
    Rails.cache.fetch "#{sku.class.to_s}_count_#{sku.id}_#{sku.updated_at.to_i}", :expires_in => 10.minutes do
      sku.comments.count
    end
  end

end
