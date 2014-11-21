# -*- encoding : utf-8 -*-
class AskForDapei < ActiveRecord::Base
  attr_accessible :title, :comments_count, :dapei_id, :dispose_count, :level, :likes_count, :matter_id, :reward, :user_id, :status, :dapeis_count, :digest, :url, :tag
  belongs_to :user
  belongs_to :matter
  has_many :dapei_responses , :foreign_key => :request_id
  acts_as_taggable
  #has_many :dapei_responses, :as => :request, :dependent=>:destroy

  acts_as_api  
  api_accessible :public,  :cache => 300.minutes do |t|
    t.add lambda{|item| item.id.to_s }, :as => :id
    t.add :title
    t.add lambda{|item| item.matter_id.to_s}, :as => :matter_id
    t.add lambda{|item| item.matter_id.to_s}, :as => :object_id
    t.add lambda{|item| item.get_thing_id }, :as => :thing_id
    t.add lambda{|item| item.get_img_width.to_s }, :as => :width
    t.add lambda{|item| item.get_img_height.to_s }, :as => :height
    t.add :get_small_jpg, :as => :small_img
    t.add :get_big_png, :as => :big_img
    t.add lambda{|item| item.comments_count.to_i.to_s}, :as => :comments_count
    t.add lambda{|item| item.likes_count.to_i.to_s}, :as => :likes_count
    t.add lambda{|item| item.incr_and_get_dispose_count.to_i.to_s}, :as => :dispose_count
    t.add lambda{|item| item.get_answers_count.to_i.to_s}, :as => :answers_count
    t.add :created_at
    t.add :updated_at
    t.add :user
    t.add :answer_desc
    t.add :get_best_dapei_img, :as => :best_answer
    t.add :share_img
    t.add :share_title
    t.add :share_desc
    t.add :share_url
  end

  acts_as_api
  api_accessible :detail,  :cache => 300.minutes do |t|
    t.add lambda{|item| item.id.to_s }, :as => :id
    t.add :title
    t.add lambda{|item| item.matter_id.to_s}, :as => :matter_id
    t.add lambda{|item| item.matter_id.to_s}, :as => :object_id
    t.add lambda{|item| item.get_img_width.to_s }, :as => :width
    t.add lambda{|item| item.get_img_height.to_s }, :as => :height
    t.add :get_small_jpg, :as => :small_img
    t.add :get_big_png, :as => :big_img
    t.add lambda{|item| item.comments_count.to_i.to_s}, :as => :comments_count
    t.add lambda{|item| item.likes_count.to_i.to_s}, :as => :likes_count
    t.add lambda{|item| item.incr_and_get_dispose_count.to_i.to_s}, :as => :dispose_count
    t.add lambda{|item| item.get_answers_count.to_i.to_s}, :as => :answers_count
    t.add :created_at
    t.add :updated_at
    t.add :user, :template => :public
    t.add :get_answers, :as => :dapei_responses, :template => :public
  end

  def answer_desc
    names = self.get_answers(3).map{|ans|ans.user.get_name if ans.user}.uniq
    names.join(',')
  end

  def get_share
    {
      :share_img => self.get_small_jpg,
      :share_title => title,
      :share_url => 'http://m.shangjieba.com',
    }
  end

  def share_img
    self.get_small_jpg
  end

  
  def share_title
    if User.current_user and User.current_user.id == self.user_id
      "我在【make美格时尚】问了一个搭配问题，谁来帮我看看。"
    else  
      self.title.to_s[0, 200]
    end
  end

  def share_desc
    ""
  end
    
  def share_url(app=false)
    op = ''
    op = '?app=1' if app
    "http://m.shangjieba.com/ask_for_dapeis/#{self.id}/view_show" + op
  end

  def get_thing_id
    if self.matter
      self.matter.image_name
    end
  end


  def get_answers(n=5)
    DapeiResponse.where("request_id=#{self.id}").order('created_at desc').limit(n)
  end

  def get_best_dapei_img
    ans = DapeiResponse.where("request_id=#{self.id}").where("dapei_id is not null").order('likes_count desc').first
    if ans and ans.get_dapei
      ans.get_dapei.img_url('m')
    else
      ""
    end
  end
 
  def get_img_width
    if self.matter
      #self.matter.width
      250
    else
      0
    end
  end


  def get_img_height
    if self.matter
      self.matter.height.to_i * 250 / self.matter.width.to_i
    else
      0
    end
  end


  def incr_and_get_dispose_count
    self.incr_dispose
    self.get_dispose_count
  end


  def get_dispose_count
    if $redis.get("request_#{self.id}")
      $redis.get("request_#{self.id}")
    else
      self.dispose_count
    end
  end


  def incr_dispose
    key = "request_#{self.id}"
    $redis.incr(key)
    key = "ask_for_dapei_pv"
    $redis.incr(key)
  end

  def self.get_pv
    key = "ask_for_dapei_pv"
    $redis.get(key).to_i +  1000000
  end


  def self.get_online
    AskForDapei.maximum('id') + DapeiResponse.maximum('id')
  end


  def get_answers_count
    DapeiResponse.where("request_id=#{self.id}").count 
  end 


  def get_small_jpg
    if self.matter
      return self.matter.get_small_jpg
    end
    ""
  end

  def get_big_png
    if self.matter
      return self.matter.get_big_png + "?imageView2/2/w/600"
    end
    ""
  end

  def update_answers_count
    #self.class.where(:id => self.id).
    #    update_all(:answers_count => self.get_answers_count) 
    self.answers_count = self.get_answers_count
    self.save
  end
    
end
