# -*- encoding : utf-8 -*-
class DapeiResponse < ActiveRecord::Base
  include Sjb::Likeable
  include Sjb::Commentable

  attr_accessible :comments_count, :dapei_id, :dispose_count, :likes_count, :request_id, :response_image, :response_text, :user_id, :digest
  has_many :photos, :as => :target

  belongs_to :user
  belongs_to :request, :class_name => "AskForDapei"

  acts_as_commentable

  after_create :send_notifications

  acts_as_api
  api_accessible :public, :cache => 300.minutes do |t|
    t.add lambda { |item| item.id.to_s }, :as => :id
    t.add lambda { |item| item.request_id.to_s }, :as => :request_id
    t.add lambda { |item| item.get_dapei }, :as => :dapei, :template => :dapei_response_list

    t.add lambda { |item| item.check_response_text }, :as => :response_text
    t.add lambda { |item| item.get_request_title }, :as => :request_title
    t.add lambda { |item| item.comments_count.to_i.to_s }, :as => :comments_count
    t.add lambda { |item| item.likes_count.to_i.to_s }, :as => :likes_count
    t.add lambda { |item| item.incr_and_get_dispose_count.to_i.to_s }, :as => :dispose_count
    t.add lambda { |item| item.like_id }, :as => :like_id
    t.add lambda { |item| item.img_urls }, :as => :photos
    t.add :is_report
    t.add :get_comments, :as => :comments
    t.add :created_at
    t.add :updated_at
    t.add :user
  end


  def img_urls(size=nil)
    img_urls=Array.new
    default_url=get_pod_url+"/assets/img.jpg"
    temp={:img_url => default_url, :width => "300", :height => "300"}
    if self.photos
      self.photos.each do |photo|
        temp = {}
        if size == :api_big
          temp[:img_url]=photo.url(:scaled_full)
          temp[:img_url] = temp[:img_url].gsub("img.shangjieba", "www.shangjieba")
        else
          temp[:img_url]=photo.url(size)
        end
        if not photo.width and not photo.height
          photo.get_dimensions
        end
        temp[:width]=photo.width
        temp[:height]=photo.height
        temp[:height] = photo.width unless photo.height
        img_urls<<temp
      end
    else
      img_urls<<temp
    end
    img_urls
  end


  def is_report
    return "0" if not User.current_user
    ua = UserActivity.find_by_user_id_and_action_and_object_type_and_object(User.current_user.id, 'report', 'DapeiResponse', self.id)
    return '1' if ua
    return '0'
  end


  def get_user_debug_name
    if self.user
      self.user.get_debug_name
    else
      'null'
    end
  end

  def get_comments
    self.comments.order('created_at DESC').limit(5)
  end


  def check_response_text
    words = ['kitty6690', '加微信']
    comment_txts = ['问题问得好', '路过', '同问', 'tw', '沙发']
    ad = false
    words.each do |w|
      txt = self.response_text.to_s
      txt = txt.downcase
      next unless self.user
      next if self.user.get_level >= 2
      next if self.user.id < 30000
      if txt.downcase.index(w) or self.user.get_level < -1
        idx = self.id % comment_txts.length
        self.response_text = comment_txts[idx]
        self.user.level = -2
        self.user.save
        break
      end
    end
    self.response_text
  end


  def like_id
    return 0 if not User.current_user
    like=Like.find_by_user_id_and_target_id_and_target_type(User.current_user.id, self.id, "DapeiResponse")
    if like
      like.id
    else
      0
    end
  end

  def like_id_s
    like_id.to_s
  end


  def get_request
    AskForDapei.find_by_id(self.request_id)
  end

  def get_request_title
    if self.get_request
      self.get_request.title.to_s
    else
      ""
    end
  end

  def get_dapei
    unless self.dapei_id.blank?
      Dapei.find_by_url(self.dapei_id)
    end
  end


  def incr_and_get_dispose_count
    self.incr_dispose
    self.get_dispose_count
  end


  def get_dispose_count
    if $redis.get("dp_res_#{self.id}")
      $redis.get("dp_res_#{self.id}")
    else
      self.dispose_count
    end
  end


  def incr_dispose
    key = "dp_res_#{self.id}"
    $redis.incr(key)
  end

  private
  def send_notifications
    if self.get_request
      user_id = self.get_request.user_id
      self.get_request.updated_at = self.created_at
      self.get_request.save
      self.get_request.update_answers_count
      PushNotification.push_dapei_comm_notify(user_id, self.request_id)
    end
  end

  def get_pod_url
    pod_url = AppConfig[:pod_url].dup
    pod_url.chop! if AppConfig[:pod_url][-1, 1] == '/'
    pod_url
  end

end
