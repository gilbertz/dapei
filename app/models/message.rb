# -*- encoding : utf-8 -*-
class Message < ActiveRecord::Base

  belongs_to :accepter, :foreign_key => :accept_id, :class_name => "User"
  belongs_to :sender, :foreign_key => :sender_id, :class_name => "User"

  after_create :send_notifications

  def user
    User.find sender_id
  end

  def user_url
    self.user.url if self.user
  end

  def user_name
    self.user.name if self.user
  end

  def user_img_small
    if self.user
      self.user.display_img_small
    else
      "http://www.shangjieba.com/assets/img.jpg"
    end
  end

  def self.send_activity_message(accept_id, type)
    messages = [
        [
            [767426, "结婚生子只为平息李云迪，爱的只有你"],
            [767500, "乖女，在你卡上打了500万，随便花花"],
            [767517, "京东不靠谱，送你黄金电脑桌好不好"],
            [767529, "赌球输了，跪求借5000万"],
            [767555, "老大，事已办妥，已把小贱人黑成狗"],
            [774986, "诚邀您来旗下“make”做签约代言人"]
        ],
        [
            [767572, "我要结婚了，对不起，爱过…"],
            [767582, "我要让所有人都知道，地球，我承包了"],
            [767602, "5000万签吗？周末吃个饭，谢霆锋陪坐"],
            [767653, "做我汤太太好吗？"],
            [767664, "亲，最近有新片吗，给个配角让我露露脸"],
            [774986, "诚邀您来旗下“make”做签约代言人 "]
        ],
        [
            [767677, "万科的演讲希望您能指点一二"],
            [767682, "周末去参加长江商学院的同学会吗？"],
            [767688, "江湖令已出，陈天桥有麻烦，望鼎力相助"],
            [767698, "办黑卡吗，我派花旗行长上门为您办理。"],
            [767705, "老板，已经打点好了，您投的球队必赢"],
            [774986, "诚邀您来旗下“make”做签约代言人"]
        ]
    ]

    messages[type].each do |message|
      m = Message.new(:sender_id => message[0], :accept_id => accept_id, :content => message[1])
      m.save
    end
  end

  private
  def send_notifications
    user=User.find(self.accept_id)
    if user
       user.notify("A new message", "Youre not supposed to see this", self)
       user.set_notify_status
       user.query_notify
    end
  end

end
