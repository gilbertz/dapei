# -*- encoding : utf-8 -*-
class Follow < ActiveRecord::Base

  extend ActsAsFollower::FollowerLib
  extend ActsAsFollower::FollowScopes

  # NOTE: Follows belong to the "followable" interface, and also to followers
  belongs_to :followable, :polymorphic => true
  belongs_to :follower,   :polymorphic => true

  after_create :send_notifications
  after_create :increment_counts
  before_destroy :decrement_counts

  acts_as_api
  api_accessible :public, :cache => 60.minutes do |t|
    #t.add :id
    t.add lambda{|follow| follow.id.to_s}, :as => :id
    t.add :follower
    t.add :following
    t.add :created_at
  end

  api_accessible :error do |t|
    t.add :errors
  end

  def follower
    self.follower_type.constantize.find(follower_id)
  end

  def following
    self.followable_type.constantize.find(followable_id)
  end

  def block!
    self.update_attribute(:blocked, true)
  end

  def send_notifications
    if(followable_type=="User")
      followable = User.find(followable_id)
      followable.notify("A new follower", "Youre not supposed to see this", self)
      followable.set_notify_status
      followable.query_notify
    end
  end

  protected
  def increment_counts
    if self.followable_type == "User"
      following_user = Userinfo.where(:user_id => self.followable_id).first
      if following_user.blank?
        following_user = Userinfo.create(:user_id => self.followable_id)
      end
      following_user.increment(:followers_count)
      following_user.save

      follower_user = Userinfo.where(:user_id => self.follower_id).first
      if follower_user.blank?
        follower_user = Userinfo.create(:user_id => self.follower_id)
      end
      follower_user.increment(:following_count)
      follower_user.save
    end
  end

  def decrement_counts
    if self.followable_type == "User"
      following_user = Userinfo.where(:user_id => self.followable_id).first
      if following_user.blank?
        following_user = Userinfo.create(:user_id => self.followable_id)
      end
      following_user.decrement(:followers_count)
      following_user.save

      follower_user = Userinfo.where(:user_id => self.follower_id).first
      if follower_user.blank?
        follower_user = Userinfo.create(:user_id => self.follower_id)
      end
      follower_user.decrement(:following_count)
      follower_user.save
    end
  end

end
