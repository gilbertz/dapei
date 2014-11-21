# -*- encoding : utf-8 -*-
class UserMailer < ActionMailer::Base
  #default :css => :email_style, :from=>"nj@wanhuir.com"
  def invite_email_bulk (name,email, recommend_shops, recommend_items, subject)
    pod_url = AppConfig[:pod_url].dup
    pod_url.chop! if AppConfig[:pod_url][-1,1] == '/'
    @root_url=pod_url
    @name=name
    @recommend_items = recommend_items
    @recommend_shops = recommend_shops
    mail(:to => email, :subject => subject)
  end

  def invite_qixi_email_bulk (name,email, recommend_shops, recommend_items, subject)
    pod_url = AppConfig[:pod_url].dup
    pod_url.chop! if AppConfig[:pod_url][-1,1] == '/'
    @root_url=pod_url
    @name=name
    @recommend_items = recommend_items
    @recommend_shops = recommend_shops
    mail(:to => email, :subject => subject)
  end

  def qunfa_mail
    p "---------------"
    email = "453567320@qq.com"
    from = "nj@wanhuir.com"
    subject = "test"
    mail(:to => email, :subject => subject)
    render :action => "invite_email_bulk"
  end



  #2013-08-22
  def eight_twenty_two (email, subject)
    mail(:to => email, :from => 'nj@wanhuir.com', :subject => subject)
  end

  def eight(email, subject)
    mail(:to => email, :from => 'noreply@weixinjie.net', :subject => subject)
  end

end
