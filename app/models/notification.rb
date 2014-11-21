# -*- encoding : utf-8 -*-

class Notification < ActiveRecord::Base
  attr_accessor :recipients
  attr_accessible :body, :subject

  belongs_to :sender, :polymorphic => :true
  belongs_to :notified_object, :polymorphic => :true
  validates_presence_of :subject, :body
  has_many :receipts, :dependent => :destroy

  scope :recipient, lambda { |recipient|
    joins(:receipts).where('receipts.receiver_id' => recipient.id,'receipts.receiver_type' => recipient.class.to_s)
  }
  scope :with_object, lambda { |obj|
    where('notified_object_id' => obj.id,'notified_object_type' => obj.class.to_s)
  }
  scope :not_trashed, lambda {
    joins(:receipts).where('receipts.trashed' => false)
  }
  scope :unread,  lambda {
    joins(:receipts).where('receipts.is_read' => false)
  }

  acts_as_api
  api_accessible :public, :cache => 60.minutes do |t|
    t.add :notified_object_type
    t.add :notified_object
    t.add :created_at
  end

  acts_as_api
  api_accessible :common, :cache => 60.minutes do |t|
    t.add :get_type, :as => :type
    t.add :get_who, :as => :who
    t.add :get_who_id, :as => :who_id
    t.add :get_avatar, :as => :avatar_url
    t.add :get_is_following, :as => :is_following
    t.add :get_object_type, :as => :object_type 
    t.add :get_object_id, :as => :object_id    
    t.add :get_object_title, :as => :object_title

    t.add :get_title, :as => :title
    t.add :get_url, :as => :id
    t.add :get_content, :as => :content
    t.add lambda{|n| n.get_photos}, :as => :photos
    #t.add :get_likes, :as => :likes, :template => :public
    t.add :get_comments, :as => :comments, :template => :public
    t.add :get_likes_count, :as => :likes_count
    t.add :get_comments_count, :as => :comments_count
    t.add :get_like_id, :as => :like_id
    t.add :get_share_url, :as => :share_url
    t.add :get_share_img, :as => :share_img
    t.add :created_at
  end 

 
  acts_as_api 
  api_accessible :notify, :cache => 60.minutes do |t|
    t.add :get_type, :as => :type
    t.add :get_who, :as => :who
    t.add :get_who_id, :as => :who_id
    t.add :get_avatar, :as => :avatar_url
    t.add :get_is_following, :as => :is_following

    t.add :get_title, :as => :title
    t.add :get_url, :as => :id 
    t.add :get_content, :as => :content
    t.add lambda{|n| n.get_photos(true)},  :as => :photos
    t.add :get_share_url, :as => :share_url
    t.add :created_at
  end  


  api_accessible :error do |t|
    t.add :errors
  end

  
  def get_type
    if self.notified_object_type == "Matter"
      "Post"
    else
      self.notified_object_type
    end
  end 

  
  def get_object_id
    if self.notified_object_type == 'Item' 
      dr = DapeiResponse.find_by_dapei_id(self.get_url)
      return dr.request_id.to_s if dr 
    end
    return ""
  end

  def get_object_type
    if self.notified_object_type == 'Item'
      dr = DapeiResponse.find_by_dapei_id(self.get_url)
      return "AskForDapei" if dr
    end
    return ""
  end


  def get_object_title
    if self.notified_object_type == 'Item'
      dr = DapeiResponse.find_by_dapei_id(self.get_url)
      return dr.get_request.title if dr
    end
    return ""
  end



  def get_who
    return self.notified_object.follower.name.to_s if self.notified_object_type == "Follow"
    return self.notified_object.user_name.to_s if self.notified_object_type == "Comment" or self.notified_object_type == "Like"
    return self.notified_object.brand_name.to_s if self.notified_object_type == "Discount"
    return self.notified_object.user_name.to_s if self.notified_object_type == "Dapei" or self.notified_object_type == "Item"
    return User.get_admin.name.to_s if self.notified_object_type == "User"
    return self.notified_object.user_name.to_s if self.notified_object_type == "Post" or self.notified_object_type == "Message"
    return self.notified_object.user_name.to_s if self.notified_object_type == "Matter"
  end
   
  def get_who_id
    return self.notified_object.follower.url if self.notified_object_type == "Follow"
    return self.notified_object.user_url if self.notified_object_type == "Comment" or self.notified_object_type == "Like"
    return self.notified_object.brand.id if self.notified_object_type == "Discount" 
    return self.notified_object.user_url if self.notified_object_type == "Dapei" or self.notified_object_type == "Item"
    return User.get_admin.url if self.notified_object_type == "User"
    return self.notified_object.user_url if self.notified_object_type == "Post" or self.notified_object_type == "Message"
    return self.notified_object.user_url if self.notified_object_type == "Matter" 
  end

  def get_avatar
    return self.notified_object.follower.display_img_small if self.notified_object_type == "Follow" 
    return self.notified_object.user_img_small if self.notified_object_type == "Comment" or self.notified_object_type == "Like"
    return self.notified_object.brand_avatar_url if self.notified_object_type == "Discount"
    return self.notified_object.user_img_small if self.notified_object_type == "Dapei" or self.notified_object_type == "Item"
    return User.get_admin.display_img_small if self.notified_object_type == "User"
    return self.notified_object.user_img_small if self.notified_object_type == "Post" or self.notified_object_type == "Message" 
    return self.notified_object.user_img_small if self.notified_object_type == "Matter" 
  end

  def get_title
    return  self.notified_object.follower.name.to_s + " 关注了你" if self.notified_object_type == "Follow"
    if self.notified_object_type == "Comment"
      if User.current_user and self.notified_object.tuid == User.current_user.id
        return self.notified_object.user_name + "" + self.notified_object.comment.to_s if self.notified_object.tuid == User.current_user.id
      else
        return self.notified_object.user_name + "评论了你的作品:" + self.notified_object.comment.to_s
      end
    end
    return self.notified_object.user_name + " 赞了你的作品" if self.notified_object_type == "Like"
    return self.notified_object.title.to_s if self.notified_object_type == "Discount" or self.notified_object_type == "Post"
    if self.notified_object_type == "Dapei" or self.notified_object_type == "Item"
      return self.notified_object.show_title.to_s 
    end
    return "欢迎加入上街吧Family！" if self.notified_object_type == "User"
    return self.notified_object.content.to_s if self.notified_object_type == "Message"
    return self.notified_object.get_notify_title if self.notified_object_type == "Matter"
  end

  def get_url
    return "" if self.notified_object_type == "Follow"
    return self.notified_object.comm_url if self.notified_object_type == "Comment"
    return self.notified_object.liked_id if self.notified_object_type == "Like"
    return self.notified_object.id if self.notified_object_type == "Discount"
    return self.notified_object.url if self.notified_object_type == "Dapei" or self.notified_object_type == "Item"
    return self.notified_object.id if self.notified_object_type == "Post"
    return ""
  end

  def get_share_img
    return self.notified_object.share_img if self.notified_object_type == "Dapei" or self.notified_object_type == "Item"
    return ""
  end

  def get_content
    return "" if self.notified_object_type == "Follow"
    return "" if self.notified_object_type == "Comment" or self.notified_object_type == "Like"
    return self.notified_object.description if self.notified_object_type == "Discount" 
    #return self.notified_object.content if self.notified_object_type == "Post"
    return self.notified_object.desc if self.notified_object_type == "Dapei" or self.notified_object_type == "Item" 
    return ""
  end

  def get_photos(small = false)
    return [] if self.notified_object_type == "Follow"
    return Dapei.find_by_url(self.notified_object.comm_url).get_dpimg_urls if self.notified_object_type == "Comment" 
    return Dapei.find_by_url(self.notified_object.liked_id).get_dpimg_urls if self.notified_object_type == "Like" and Dapei.find_by_url(self.notified_object.liked_id)
    return self.notified_object.discount_img_urls if self.notified_object_type == "Discount"
    return self.notified_object.get_dpimg_urls(small) if self.notified_object_type == "Dapei" or self.notified_object_type == "Item"
    return self.notified_object.post_img_urls if self.notified_object_type == "Post"
    return self.notified_object.img_urls if self.notified_object_type == "Matter"
    return []
  end

  def get_is_following
    if ['Follow', 'Comment', 'Like', 'Item', 'Post', 'Message'].include?( self.notified_object_type)
      u = User.find_by_url(self.get_who_id)
      return u.is_following if u
    end
    return "0" 
 end
  
 def get_comments
     if self.notified_object_type == "Discount" or self.notified_object_type == "Item" or self.notified_object_type == "Post"
         return Comment.dup( self.notified_object.comments.order('updated_at DESC').limit(5) )
     else
         []
     end
 end

 def get_likes
     if self.notified_object_type == "Discount" or self.notified_object_type == "Item" or self.notified_object_type == "Post"
         return self.notified_object.likes.order('created_at DESC').limit(10).map(&:user)
     else
         []
     end
 end


 def get_likes_count
     if self.notified_object_type == "Discount" or self.notified_object_type == "Item" or self.notified_object_type == "Post"
         return self.notified_object.likes_count.to_i.to_s
     else
         "0"
     end
 end

 
 def get_comments_count
     if self.notified_object_type == "Discount" or self.notified_object_type == "Item" or self.notified_object_type == "Post"
         return self.notified_object.comments_count.to_i.to_s
     else
         "0"
     end
 end


 def get_like_id
     if self.notified_object_type == "Discount" or self.notified_object_type == "Item" or self.notified_object_type == "Post"
         return self.notified_object.like_id_s
     else
         "0"
     end  
 end  


  def get_share_url
     if ['Discount', 'Item', 'Post', 'Matter'].include?( self.notified_object_type )
         return self.notified_object.share_url
     else
         "0"
     end
 end


  include Concerns::ConfigurableMailer

  class << self
    #Sends a Notification to all the recipients
    def notify_all(recipients,subject,body,obj = nil,sanitize_text = true,notification_code=nil)
      notification = Notification.new({:body => body, :subject => subject})
      notification.recipients = recipients.respond_to?(:each) ? recipients : [recipients]
      notification.recipients = notification.recipients.uniq if recipients.respond_to?(:uniq)
      notification.notified_object = obj if obj.present?
      notification.notification_code = notification_code if notification_code.present?
      return notification.deliver sanitize_text
    end

    #Takes a +Receipt+ or an +Array+ of them and returns +true+ if the delivery was
    #successful or +false+ if some error raised
    def successful_delivery? receipts
      case receipts
      when Receipt
        receipts.valid?
        return receipts.errors.empty?
       when Array
         receipts.each(&:valid?)
         return receipts.all? { |t| t.errors.empty? }
       else
         return false
       end
    end
  end

  #Delivers a Notification. USE NOT RECOMENDED.
  #Use Mailboxer::Models::Message.notify and Notification.notify_all instead.
  def deliver(should_clean = true)
    self.clean if should_clean
    temp_receipts = Array.new
    #Receiver receipts
    self.recipients.each do |r|
      msg_receipt = Receipt.new
      msg_receipt.notification = self
      msg_receipt.is_read = false
      msg_receipt.receiver = r
      temp_receipts << msg_receipt
    end
    temp_receipts.each(&:valid?)
    if temp_receipts.all? { |t| t.errors.empty? }
      temp_receipts.each(&:save!)   #Save receipts
      self.recipients.each do |r|
        #Should send an email?
        if Mailboxer.uses_emails
          email_to = r.send(Mailboxer.email_method,self)
          unless email_to.blank?
            get_mailer.send_email(self,r).deliver
          end
        end
      end
      self.recipients=nil
    end
    return temp_receipts if temp_receipts.size > 1
    return temp_receipts.first
  end

  #Returns the recipients of the Notification
  def recipients
    if @recipients.blank?
      recipients_array = Array.new
      self.receipts.each do |receipt|
        recipients_array << receipt.receiver
      end
    return recipients_array
    end
    return @recipients
  end

  #Returns the receipt for the participant
  def receipt_for(participant)
    return Receipt.notification(self).recipient(participant)
  end

  #Returns the receipt for the participant. Alias for receipt_for(participant)
  def receipts_for(participant)
    return receipt_for(participant)
  end

  #Returns if the participant have read the Notification
  def is_unread?(participant)
    return false if participant.nil?
    return !self.receipt_for(participant).first.is_read
  end

  def is_read?(participant)
    !self.is_unread?(participant)
  end

  #Returns if the participant have trashed the Notification
  def is_trashed?(participant)
    return false if participant.nil?
    return self.receipt_for(participant).first.trashed
  end

  #Mark the notification as read
  def mark_as_read(participant)
    return if participant.nil?
    return self.receipt_for(participant).mark_as_read
  end

  #Mark the notification as unread
  def mark_as_unread(participant)
    return if participant.nil?
    return self.receipt_for(participant).mark_as_unread
  end

  #Move the notification to the trash
  def move_to_trash(participant)
    return if participant.nil?
    return self.receipt_for(participant).move_to_trash
  end

  #Takes the notification out of the trash
  def untrash(participant)
    return if participant.nil?
    return self.receipt_for(participant).untrash
  end


  include ActionView::Helpers::SanitizeHelper

  #Sanitizes the body and subject
  def clean
    unless self.subject.nil?
      self.subject = sanitize self.subject
    end
    self.body = sanitize self.body
  end

  #Returns notified_object. DEPRECATED
  def object
    warn "DEPRECATION WARNING: use 'notify_object' instead of 'object' to get the object associated with the Notification"
    notified_object
  end

end
