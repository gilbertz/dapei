# -*- encoding : utf-8 -*-
class Post < ActiveRecord::Base
  include Sjb::Likeable
  include Sjb::Commentable

  require "open-uri"

  belongs_to :user, :inverse_of=>:posts, :counter_cache => true
  has_many :photos, :as => :target, :dependent=>:destroy
  validates :title, :presence=>true
  belongs_to :category

  default_scope -> { order("id desc") }
  scope :is_show, -> { where("is_show = 1")}

  attr_accessible :title, :content, :desc, :user_id, :photos, :area, :category_id, :link, :thumb, :is_show

  attr_accessor :image_url

  mount_uploader :thumb, ThumbImage

  acts_as_commentable

  after_create :format_html_new
  after_update :format_html_new, :unless => :skip_callbacks
  #after_create :send_notifications

  acts_as_api
  api_accessible :public, :cache => 300.minutes do |t|
    #t.add :id, :as=>:post_id
    t.add lambda{|post| post.id.to_s}, :as => :post_id
    t.add :title
    t.add :content
    t.add :user_url, :as=>:user_id
    t.add :user_name
    t.add :area
    t.add :link
    t.add :created_at
    t.add lambda{|post| post.likes_count.to_s}, :as => :likes_count
    t.add lambda{|post| post.comments_count.to_s}, :as => :comments_count
    #t.add :likes_count
    #t.add :comments_count
    t.add lambda{|post| post.img_url(:thumb_small)}, :as => :img_sqr_small
    t.add lambda{|post| post.img_url(:thumb_medium)}, :as => :img_sqr_medium
  end

  api_accessible :error do |t|
    t.add :errors
  end

  #TODO
  #after_create :send_notifications

  def user_url
    self.user.url
  end

  def user_name
    self.user.name
  end

  def has_liked?
    if User.current_user and Like.has_liked?(User.current_user.id, self.id, "Post")
      return true
    else
      return false
    end
    self.user.url
  end

  def user_name
    self.user.name
  end

  def like_id
    like=Like.find_by_user_id_and_target_id_and_target_type(User.current_user.id, self.id, "Post")
    like.id
  end

  def like_id_s
    like_id="0"
    if has_liked?
      like=Like.find_by_user_id_and_target_id_and_target_type(User.current_user.id, self.id, "Post")
      like_id=like.id.to_s
    end
    like_id
  end

  def img_url(size=nil)
    img_url=get_pod_url+"/assets/img.jpg"
    if self.photos and self.photos.length>0
      self.photos.sort_by{|photo| photo.created_at}
      photo=self.photos.last
      img_url=photo.url(size)
    end
    img_url
  end

  def self.newer(post)
    where("posts.user_id = ? and posts.created_at > ?", post.user_id, post.created_at).reorder('posts.created_at ASC').first
  end

  def self.older(post)
    where("posts.user_id = ? and posts.created_at < ?", post.user_id, post.created_at).reorder('posts.created_at DESC').first
  end

  def format_html
    self.content = self.content.gsub(/style=\"(.*?)\"/, "")
    img_dict = {}
    self.content.scan(/src=\"(.*?)\"/).each{ |m|
      if not /uploads/ =~ m[0]
        #p m[0]
        img_fn = Digest::MD5.hexdigest(m[0])
        img_url =  AppConfig[:remote_image_domain] + "/uploads/post/#{img_fn}.jpg"
        `wget  -t 10  -nc -c -x -O /var/www/shangjieba/public/uploads/post/#{img_fn}.jpg #{m[0]}`
        #p img_url, img_fn
        img_dict[m[0]] = img_url
        #self.content = self.content.gsub(m[0], img_url) 
      end
    }
    img_dict.each do |k, v|
      self.content = self.content.gsub(k, v)
    end
    #p self.content
    self.save
  end

  def format_html_new
    img_dict = {}
    self.content.scan(/src=\"(.*?)\"/).each{ |m|

      if not /qingchao1\.qiniudn\.com/ =~ m[0]

        if /uploads\/image/ =~ m[0]
          img_dict[m[0]] = "http://qingchao1.qiniudn.com#{m[0]}"
        else
          img_fn = Digest::MD5.hexdigest(m[0])
          img_url =  AppConfig[:remote_image_domain] + "/uploads/post/#{img_fn}.jpg"
          File.open("/var/www/shangjieba/public/uploads/post/#{img_fn}.jpg", "wb") do |f|
            f.write open(m[0]).read
          end
          img_dict[m[0]] = img_url
        end

      end
      #else
      #  if (/uploads\/image/ =~ m[0]) == 1
      #    img_url =  AppConfig[:remote_image_domain] + m[0]
      #    img_dict[m[0]] = img_url
      #  end
      #end
    }

    img_dict.each do |k, v|
      self.content = self.content.gsub(k, v)
    end
    @skip_callbacks = true
    self.save
  end

  def user_img_small
    if self.user
      self.user.display_img_small
    else
      "http://www.shangjieba.com/assets/img.jpg"
    end
  end


  def post_img_urls
    img_urls = Array.new
    if self.photos and self.photos.length>0
      self.photos.each do |photo|
        temp = {}
        temp[:img_url]=photo.url(nil)
        temp[:width]=photo.width
        temp[:height]=photo.height
        img_urls<<temp
      end
    else
      default_url = "http://www.shangjieba.com/assets/img.jpg"
      default_url = self.image_thumb_url unless self.thumb_url.blank?
      default_url = self.image_url unless self.image_url.blank?
      temp={:img_url=>default_url, :width=>"484", :height=>"180"}
      img_urls<<temp
    end
    img_urls
  end

  def share_url
    return self.link unless self.link.blank?
    return "http://www.shangjieba.com:8080/posts/#{self.id}"
  end

  def random_string
    SecureRandom.hex(10)
  end


  def qiniu_thumb_url
    AppConfig[:remote_image_domain] + "#{self.thumb_url}"
  end


  def self.cache_posts(page, per_page)
    #Rails.cache.fetch "posts/page/#{page}/per_page/#{per_page}", :expires_in => 100.minutes do
      Post.is_show.page(page).per(per_page)
    #end
  end

  def image_thumb_url
    AppConfig[:remote_image_domain] + "#{self.thumb_url}"
  end

  def link_url
    unless link.blank?
      link
    else
      "http://www.shangjieba.com:8080/posts/#{self.id}"
    end
  end

  def created_at_time
    self.created_at.strftime("%Y-%m-%d %H:%M:%S")
  end

  private
  def send_notifications
    if true
      # self.user.followers_by_type('User').each do |user|
      #   user.set_ssq_status(self)
      #   user.set_ssq_notify_img(self.img_url(:thumb_small) )
      #   user.query_notify
      # end
    end
  end

  def skip_callbacks
    @skip_callbacks
  end

  def get_pod_url
    pod_url = AppConfig[:pod_url].dup
    pod_url.chop! if AppConfig[:pod_url][-1,1] == '/'
    pod_url
  end
end
