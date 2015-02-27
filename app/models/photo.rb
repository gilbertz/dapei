# -*- encoding : utf-8 -*-
#   Copyright (c) 2009, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require "base64"

class Photo < ActiveRecord::Base
  acts_as_taggable_on :brand, :price, :theme
  # has_many :active_taggings ,:class_name => "Tagging" ,:as => :taggable
  has_many :tag_infos


  require 'carrierwave/orm/activerecord'
  
  mount_uploader :processed_image, ProcessedImage
  mount_uploader :unprocessed_image, UnprocessedImage
  attr_accessor  :image_url

  # Sjb_root = "/var/www/shangjieba"
  Sjb_root = Rails.root

  acts_as_api
    api_accessible :public, :cache => 300.minutes do |t|
      t.add :id     
      t.add :created_at
      t.add :text
      #t.add :author
      t.add lambda { |photo|
        { :small => photo.url(:thumb_small),
          :medium => photo.url(:thumb_medium),
          :large => photo.url(:scaled_full) }
      }, :as => :sizes
      t.add lambda { |photo|
        { :height => photo.height,
          :width => photo.width }
      }, :as => :dimensions
    end

  belongs_to :target, :polymorphic => true

  #before_destroy :ensure_user_picture
  #after_destroy :clear_empty_status_message
  belongs_to :author, :class_name => 'User'

  after_create do
    queue_processing_job #if self.author.local?
  end

  def self.correct_img_type?(type)
    types=["jpg", "jpeg", "png", "gif", "PNG", "JPEG", "PNG", "GIF"]
    if types.include?(type)
      return true
    else
      return false
    end
  end

  def self.build_photo(current_user, upload_imgs, receive_img, receive_img_type, target_id, target_type)
      if upload_imgs
         for photo_id in upload_imgs
            photo = Photo.find_by_id(photo_id)
            photo.target_id = target_id
            photo.target_type = target_type
            photo.save!
         end
      elsif receive_img
        bi_image=Base64::decode64(receive_img)
        file_name = SecureRandom.hex(10)+"."+receive_img_type
        file = Tempfile.new(file_name, {:encoding =>  'BINARY'})
        file.print bi_image.force_encoding('BINARY')
        att_content_type = "application/octet-stream"
        Tempfile.send(:define_method, "content_type") {return att_content_type}
        Tempfile.send(:define_method, "original_filename") {return file_name}
        photo_params={:user_file=>file}
        @photo = current_user.build_post(:photo, photo_params)
        @photo.target_id=target_id
        @photo.target_type=target_type
        @photo.save!
      end
  end

  def self.build_user_avatar(current_user, upload_img, receive_img, receive_img_type, target_id, target_type)
      if upload_img
        photo = Photo.find_by_id(upload_img)
        if photo
          photo.target_id = target_id
          photo.target_type = target_type
          photo.save!
        end
      elsif receive_img
        bi_image=Base64::decode64(receive_img)
        file_name = SecureRandom.hex(10)+"."+receive_img_type
        file = Tempfile.new(file_name, {:encoding =>  'BINARY'})
        file.print bi_image.force_encoding('BINARY')
        att_content_type = "application/octet-stream"
        Tempfile.send(:define_method, "content_type") {return att_content_type}
        Tempfile.send(:define_method, "original_filename") {return file_name}
        photo_params={:user_file=>file}
        @photo = current_user.build_post(:photo, photo_params)
        @photo.target_id=target_id
        @photo.target_type=target_type
        @photo.save!
      end
  end

  def self.build_avatar(current_user, receive_img, receive_img_type)
        bi_image=Base64::decode64(receive_img)
        file_name = SecureRandom.hex(10)+"."+receive_img_type
        file = Tempfile.new(file_name, {:encoding =>  'BINARY'})
        file.print bi_image.force_encoding('BINARY')
        att_content_type = "application/octet-stream"
        Tempfile.send(:define_method, "content_type") {return att_content_type}
        Tempfile.send(:define_method, "original_filename") {return file_name}
        photo_params={:user_file=>file}
        @photo = current_user.build_post(:photo, photo_params)
        @photo.save!
        @photo.id
  end

  def self.initialize(params = {})
    photo = self.new
    photo.author = params[:author]
    #photo.public = params[:public] if params[:public]
    photo.pending = params[:pending] if params[:pending]
    #photo.diaspora_handle = photo.author.diaspora_handle
    photo.random_string = SecureRandom.hex(10)

    if params[:user_file] or  params[:file]
      #print("*****************************************************************************************************************")
      #content = File.binread(params[:user_file])
      #base64_img = Base64::encode64(content)
      #print base64_img
      #filename="/home/saibaobei/zhaojl/shangjieba/test_img"
      #file=File.new(filename, "w")
      #file.print base64_img  
      #file.close    

      #filename="/home/saibaobei/zhaojl/shangjieba/test_img"
      #file=File.new(filename, "r")
      #content=File.read(file)
      #print content
      #bincontent=Base64::decode64(base64_img)
      #if content==bincontent 
        #print "============================================"
      #end
      #file2 = File.open("test_img2","w+")
       
      #filename2="test_imgddd2.jpg20130219-32615-rqcfnt"
      #open(filename2, 'wb+') {|file| file.syswrite(bincontent)} 
      #file2=File.new(filename2)
      #file2=File.open(filename2)
      #newcontent =File.binread(file2)
      #if content==newcontent
        #print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
      #end
      #print params
      #print File.binread(file2)
      #print bincontent
      #filename2="test_img2"
      #file2 = File.open("test_img2","w+")
      #file2=File.new(filename2, "r")
      #file2.print bincontent 

      if not params[:user_file] 
         params[:user_file] = params[:file]
      end
      image_file=params[:user_file]

      params.delete(:user_file)
      photo.unprocessed_image.store! image_file

    elsif params[:image_url]
      begin
        photo.remote_unprocessed_image_url = params[:image_url]
      rescue => e
        last_part = params[:image_url].split("/").last
        case last_part
        when /.jpg/
          ext = ".jpg"
        when /.png/
          ext = ".png"
        when /.gif/
          ext = ".gif"
        else
          ext = ".jpg"
        end
        file_name = Digest::MD5.hexdigest(params[:image_url])
        `wget #{params[:image_url]} -O /data/uploads/images/#{file_name}#{ext}`
        photo.remote_unprocessed_image_url = "http://qingchao1.qiniudn.com/uploads/images/#{file_name}#{ext}"
      end
      photo.unprocessed_image.store!
    end

    photo.update_remote_path
    photo
  end

  def self.retract_photos(owner)
    if owner.photos and owner.photos.length>0
      owner.photos.each do |photo|
        photo.destroy  
      end
    end
  end

  def processed?
    processed_image.path.present?
  end

  def update_remote_path
    return if self.unprocessed_image.url.nil?
    unless self.unprocessed_image.url.match(/^https?:\/\//)
      pod_url = AppConfig[:remote_image_domain].dup
      pod_url.chop! if AppConfig[:remote_image_domain][-1,1] == '/'
      remote_path = "#{pod_url}#{self.unprocessed_image.url}"
    else
      remote_path = self.unprocessed_image.url
    end

    name_start = remote_path.rindex '/'
    self.remote_photo_path = "#{remote_path.slice(0, name_start)}/"
    self.remote_photo_name = remote_path.slice(name_start + 1, remote_path.length)
  end

  def has_face
    photo_file = Sjb_root + "/public/uploads/images/" + self.remote_photo_name
    if $redis.get( self.remote_photo_name )
      $redis.get( self.remote_photo_name )
    else
      unless FileTest::exist?( photo_file )
        `wget #{self.url} -O #{photo_file}`
      end
      dir = "/data/ImageDispose/image/select_material"
      res = `cd #{dir} && ./select_material #{photo_file} ./faceconfig.xml`
      is = (res.strip == "1")
      $redis.set( self.remote_photo_name, is)
      return is
    end
  end

  def url(name = nil)
    unless self.remote_photo_path
      self.remote_photo_path = AppConfig[:remote_image_domain].dup + "/uploads/images/"
    end
    if self.remote_photo_path
      if self.remote_photo_path == "http://www.shangjieba.com/uploads/images/"
         self.remote_photo_path = AppConfig[:remote_image_domain].dup + "/uploads/images/"
      end
      if name and self.remote_photo_path
        option = ""
        name = name.to_s
        option = "?imageView2/1/w/300/h/400" if name == "normal_medium"
        option = "?imageView2/1/w/150/h/200" if name == "normal_small"
        option = "?imageView2/1/w/220/h/220" if name == "thumb_medium"
        option = "?imageView2/1/w/242/h/180" if name == "wide_half"
        option = "?imageView2/1/w/100/h/100" if name == "thumb_small"
        option = "?imageView2/2/w/100" if name == "thumb_color"
       
        #name = name.to_s + '_' if name
        #if self.n2s
        #  name = name.gsub("normal_small", "scaled_medium").gsub("normal_medium", "scaled_medium")
        #end
        self.remote_photo_path + self.remote_photo_name.to_s + option
      elsif self.remote_photo_path
        self.remote_photo_path + self.remote_photo_name.to_s
      end
    elsif processed?
      processed_image.url(name)
    else
      unprocessed_image.url(name)
    end
  end


  def get_url
    if self.remote_photo_path == "http://www.shangjieba.com/uploads/images/"
       self.remote_photo_path = AppConfig[:remote_image_domain].dup + "/uploads/images/"
    end
    return self.remote_photo_path + self.remote_photo_name
  end


  def get_dimensions
    image = MiniMagick::Image.open( self.get_url )
    self.width = image[:width].to_i
    self.height = image[:height].to_i
    self.save
  end


  #def ensure_user_picture
  #  profiles = Profile.where(:image_url => url(:thumb_large))
  #  profiles.each { |profile|
  #    profile.image_url = nil
  #    profile.save
  #  }
  #end

  def thumb_hash
    {:thumb_url => url(:thumb_medium), :id => id, :album_id => nil}
  end

  def queue_processing_job
    #Resque.enqueue(Jobs::ProcessPhoto, self.id)
    #self.processed_image.store!(self.unprocessed_image)
    #self.save!
  end

  def mutable?
    true
  end

  def self.attach(img_url, obj=nil, dp=false)
      img_url = img_url.gsub(/.jpg\?(.*?)$/, '.jpg')
      img_url = "http://" + img_url unless img_url =~ /http:\/\/|https:\/\//

      return if not img_url or img_url == ""
      pid = Digest::MD5.hexdigest( img_url )
      p = Photo.find_by_digest(pid)
      return p if p
      p img_url

      photo_params={:image_url=>img_url }
      user = User.find_by_id(1)
      photo = user.build_post(:photo, photo_params)
      photo.digest = Digest::MD5.hexdigest( img_url )
      
      if obj
        photo.target_id = obj.id
        photo.target_type=obj.class.name
      end
      
      photo.dp = dp if dp
      photo.save!
      return photo
  end


  #api 传过来的数据格式
  def add_tag_info(tag,tag_type)
    tag_info = self.tag_infos.build
    tag_info.name = tag['name']
    tag_info.tag_type = tag_type
    tag_info.coord = "#{tag['taginfo']['point_X']}_#{tag['taginfo']['point_Y']}"
    tag_info.direction = tag['taginfo']['direction']
    tag_info.save!
  end
  #scope :on_statuses, lambda { |post_guids|
  #  where(:status_message_guid => post_guids)
  #}
end
