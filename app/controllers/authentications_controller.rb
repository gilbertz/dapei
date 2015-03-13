# -*- encoding : utf-8 -*-
class AuthenticationsController < Devise::OmniauthCallbacksController


  def weibo
    cookies[:l] = { :value => "#{Time.now.to_i}", :expires => 10.year.from_now }

    auth = request.env['omniauth.auth']
    print auth
    redirect_to root_path if auth.blank?
    @user=nil
    @user=Authentication.find_from_hash(auth)
    if(@user)
      print @user
      print "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      #print @user.authentications
      cookies[:userid] = { :value => "#{@user.url}", :expires => 10.year.from_now }
      sign_in_and_redirect(:user, @user)
      #redirect_to "/"
    else
      @username="dpms"+Devise.friendly_token[0,20]
      @email=@username+"@dapeimishu.com"
      @password=Devise.friendly_token[0,20]
      @authinfo={:name=>auth["info"]["name"], :email=>@email, :password=>@password, :remember_me=>1, :desc=>auth["info"]["description"], 
        :profile_img_url=>auth["info"]["image"]}
      @user = User.new(@authinfo)
      if @user.save
        @user=Authentication.create_from_hash(auth, @user)
        #print @user
        #print @user.errors.full_messages
        cookies[:userid] = { :value => "#{@user.url}", :expires => 10.year.from_now }
        sign_in_and_redirect @user
        #redirect_to "/"
      else
        redirect_to "/"
      end
    end
  end


  def sign_in_or_redirect
    if params[:rurl]
      sign_in @user
      redirect_to params[:rurl]
    else
      sign_in_and_redirect @user
    end
  end

  
  def weixin
    cookies[:l] = { :value => "#{Time.now.to_i}", :expires => 10.year.from_now }

    auth = request.env['omniauth.auth']
    print auth
    redirect_to root_path if auth.blank?
    @user=nil
    @user=Authentication.find_from_hash(auth)
    if(@user)
      print @user
      print "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
      #print @user.authentications
      cookies[:userid] = { :value => "#{@user.url}", :expires => 10.year.from_now }
      sign_in_or_redirect
      #redirect_to "/"
    else
      @username="dpms"+Devise.friendly_token[0,20]
      @email=@username+"@dapeimishu.com"
      @password=Devise.friendly_token[0,20]
      @authinfo={:name=>auth["info"]["name"], :email=>@email, :password=>@password, :remember_me=>1, :desc=>auth["info"]["description"],
        :profile_img_url=>auth["info"]["image"]}
      @user = User.new(@authinfo)
      if @user.save
        @user=Authentication.create_from_hash(auth, @user)
        #print @user
        #print @user.errors.full_messages
        cookies[:userid] = { :value => "#{@user.url}", :expires => 10.year.from_now }
        sign_in_or_redirect
        #redirect_to "/"
      else
        redirect_to "/"
      end
    end
  end


  def qq_connect
    cookies[:l] = { :value => "#{Time.now.to_i}", :expires => 10.year.from_now }

    auth = request.env['omniauth.auth']
    Rails.logger.info("#{auth}")
    redirect_to root_path if auth.blank?
    @user=nil
    @user=Authentication.find_from_hash(auth)
    if(@user)
      cookies[:userid] = { :value => "#{@user.url}", :expires => 10.year.from_now }
      sign_in_and_redirect(:user, @user)
      #redirect_to "/"
    else
      @username="dpms"+Devise.friendly_token[0,20]
      @email=@username+"@dapeimishu.com"
      @password=Devise.friendly_token[0,20]
      #@authinfo={:email=>@email, :password=>@password, :remember_me=>1, :preurl=>@username}
      @authinfo={:name=>auth["info"]["nickname"], :email=>@email, :password=>@password, :remember_me=>1, :desc=>auth["info"]["msg"],  
        :profile_img_url=>auth["info"]["figureurl_qq_2"]}
      @user = User.new(@authinfo)
      if @user.save
        @user=Authentication.create_from_hash(auth, @user)
        #print @user
        #print @user.errors.full_messages
        cookies[:userid] = { :value => "#{@user.url}", :expires => 10.year.from_now }
        sign_in_and_redirect @user
        #redirect_to "/"
      else
        redirect_to "/"
      end
    end

  end

end
