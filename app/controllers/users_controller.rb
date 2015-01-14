# -*- encoding : utf-8 -*-

class UsersController < ApplicationController
  layout "new_app"
  before_filter :authenticate_user!, :only=>[:update, :destroy, :unread_notification_count, :get_user_info]
  before_filter :get_user, :except=>[:index_all]

  def index_all
    authorize! :index, @user, :message => 'Not authorized as an administrator.'
    #@users = User.all
    if params[:q]
      searcher = Searcher.new(nil, "user", params[:q], "new", 10, params[:page])
      @users = searcher.search()
    else
      @users = User.order('created_at DESC').paginate(:page=>params[:page], :per_page=>1000)
    end
  end

  def push
    deploy_status = 2
    deploy_status = params[:deploy_status] if params[:deploy_status]
    user_id = 1 
    user_id = params[:user_id] if params[:user_id]
    u = User.find_by_id user_id
    u =  User.find_by_url user_id unless u
    user_id = u.id

    t = 0
    t =  params[:t].to_i if params[:t]
    msg = 'hi, make'
    msg =  params[:msg] if params[:msg]
    dp = Dapei.where("level >= 2").last  
    durl = dp.url
    durl = params[:durl] if params[:durl]
    dr_id = AskForDapei.last.id
    
    case t
      when 1 then
        PushNotification.push_notify(user_id, deploy_status)
      when 2 then
        PushNotification.push_ssq(user_id, deploy_status) 
      when 3 then
        PushNotification.push_dapei_comm_msg(user_id, deploy_status) 
      when 4 then
        PushNotification.push_dapei_comm_notify(user_id, dr_id, '', deploy_status)
      when 5 then
        PushNotification.push_dapei_msg(user_id, durl, deploy_status)
      when 6 then
        PushNotification.push_dapei_pv(user_id, durl, deploy_status)
      when 7 then
        PushNotification.push_msg(user_id, msg, deploy_status)
      when 8 then
        PushNotification.push_status(user_id, msg, deploy_status) 
      else
        PushNotification.push_activity(user_id, deploy_status)  
    end
    intr = '''
        succ!! <br/> <br/> 
        eg http://www.shangjieba.com:2014/users/:user_id/push?t=1&durl=&deploy_status=2&msg=
        <br/> 
        参数说明: <br/>
        user_id: 用户的id <br/>
        deploy_status: 1表示开发环境，2生成环境，默认为2. <br/> 
        t: <br/> 
          t=0 默认，推送活动 <br/> 
          t=1 消息中心 <br/> 
          t=2 时尚圈 <br/> 
          t=3 搭配问问通知 <br/> 
          t=4 搭配问问新回答 <br/> 
          t=5 搭配评论  <br/> 
          t=6 搭配pv提醒 <br/> 
          t=7 消息通知，应用首页 <br/>
          t=8 状态通知 
        durl: 搭配id <br/> 
        msg:  消息内容   <br/> 
<br/> 
    '''
    render :text => intr
  end
  

  def ssq
    @dapeis = []
    @brand_discounts = []
    @show_post = false
    @show_post = true if params[:show_post]  
    @matters = []
 
    user_ids = []
    brand_ids = []
    
    if params[:dapei_id] 
      @dapeis = [ Dapei.by_url( params[:dapei_id] ) ]
    elsif params[:discount_id] 
      @brand_discounts = [ Discount.find_by_id( params[:discount_id] ) ]
    elsif params[:post_id]
      @posts = [ Post.find_by_id( params[:post_id] ) ]
      @show_post = true
    else
      unless params[:user_id]
        @following_users = @user.following_by_type('User') 
        @following_brands = Brand.liked_by(@user).uniq
  
        user_ids = @following_users.map{|u| u.id } 
        brand_ids =  @following_brands.map{|b| b.id}  
    
        #add self user
        user_ids << @user.id
      else
        u = User.find_by_url( params[:user_id] )
        if u.id == 1
          @following_brands = Brand.liked_by( u ).uniq
          brand_ids =  @following_brands.map{|b| b.id}
        end
        user_ids << u.id if u
        @dapeis=Dapei.dapeis_by(u).page(params[:page]).per(5)
        unless u.is_real
          @dapeis.each do |dp|
            dp.user_id = u.id
            dp.url =  dp.url + "@#{u.url}"
          end
        end
        #@matters = Matter.where(:user_id => user_ids).paginate(:page=>params[:page], :per_page=>5).order("created_at desc")
        @show_post = true 
      end

      unless params[:user_id]
        @dapeis = Dapei.joins("INNER JOIN dapei_infos ON dapei_infos.dapei_id = items.id").where( "items.deleted is null " ).where(:category_id => 1001).where(:user_id => user_ids).order("created_at desc").paginate(:page=>params[:page], :per_page=>5)
      end

      @brand_discounts = Discount.where("deleted is null").where(:discountable_type => "Brand" ).where(:discountable_id => brand_ids).order("created_at desc").paginate(:page=>params[:page], :per_page=>5)
      @posts = Post.where(:user_id => user_ids).where(:is_show => 1).order("created_at desc").paginate(:page=>params[:page], :per_page=>5) if @show_post 
    end
    

    @notifications = []
    @dapeis.each do |dp|
      next unless dp
      next unless dp.dapei_info
      next unless dp.get_dpimg_urls.length > 0 
      n = Notification.new
      n.notified_object_type = "Dapei"
      n.notified_object = dp
      n.created_at = dp.created_at
      @notifications << n
    end
    @brand_discounts.each do |bd|
      n = Notification.new
      n.notified_object_type = "Discount"
      n.notified_object = bd
      n.created_at = bd.created_at
      @notifications << n
    end
    if @show_post
      @posts.each do |p|
        n = Notification.new
        n.notified_object_type = "Post"
        n.notified_object = p
        n.created_at = p.created_at
        @notifications << n
      end
      @matters.each do |p|
        n = Notification.new
        n.notified_object_type = "Matter"
        n.notified_object = p
        n.created_at = p.created_at
        @notifications << n
      end
    end
   
    @notifications = @notifications.sort_by{ |n| -1 * n.created_at.to_i } 

    @user.set_ssq_read unless params[:user_id]
    respond_to do |format|   
      format.json{render_for_api :common, :json=>@notifications, :api_cache => 30.minutes, :meta=>{:result=>"0"}}
    end
  end 

  def ssq_status
    unread = false
    last_update = @user.get_ssq_status.to_i
    last_read = @user.get_ssq_read.to_i 
    unread = true if last_update >= last_read
    result = {:unread => unread,  :last_status => last_update.to_s, :last_read => last_read.to_s }
    
    render :json => {:result => result, :success => true}    
  end

  def show
    @where = "个人主页"
    respond_to do |format|
      format.html 
      if @user
        #@favorite_shops=Shop.liked_by(@user).order("created_at desc").limit(4)
        #@commented_shops=Shop.commented_by(@user).order("created_at desc").limit(4)
        #@shops=@favorite_shops
        #@favorite_items=Item.liked_by(@user).order("created_at desc").limit(4)
        #@commented_items=Item.commented_by(@user).order("created_at desc").limit(4)      
        #@items=@favorite_items
        #@posts=@user.posts.order("created_at desc").limit(12)
        @dapeis=Dapei.dapeis_by(@user).page(params[:page]).per(10)
        format.json{ render_user_json }
      else
        format.json{render :json=>{:result=>"1"}}
      end
    end
  end

  
  def info
    respond_to do |format|
      format.html
      if @user
        format.json{render_for_api :level, :json=>@user, :api_cache => 30.minutes, :meta=>{:result=>"0"}}
      else
        format.json{render :json=>{:result=>"1"}}
      end
    end
  end


  def favorite_items
    @where = "喜欢宝贝"
    if(@user)
      #@number=Item.liked_by(@user).uniq.where( "category_id != 1001").count
      #@items=Item.liked_by(@user).uniq.where( "category_id != 1001").page(params[:page]).per(10)
      @number = Sku.liked_by(@user).uniq.where( "category_id < 100").count
      @skus = Sku.liked_by(@user).uniq.where( "category_id < 100").page(params[:page]).per(10)
      @items = @skus.map{|sku| sku.wrap_item } 

      respond_to do |format|
        format.html
        format.json{render_for_api :public, :json=>@items, :api_cache => 30.minutes, :meta=>{:result=>"0", :total_count=>@number.to_s}}
      end
    else
      respond_to do |format|
        format.html
        format.json{render :json=>{:result=>"1"}}
      end
    end
  end

  def created_dapeis
    @where = "创建的搭配"
    if(@user)
      @dapeis=Dapei.dapeis_by(@user).page(params[:page]).per(10)
      unless @user.is_real
        @dapeis.each do |dp|
          dp.user_id = @user.id
        end
      end
      @number=@dapeis.count
      respond_to do |format|
        format.html
        format.json{render_for_api :dapei_list, :json=>@dapeis, :api_cache => 30.minutes, :meta=>{:result=>"0", :total_count=>@number.to_s}}
      end
    else
      respond_to do |format|
        format.html
        format.json{render :json=>{:result=>"1"}}
      end
    end
  end


  def shangjie_dapeis
    @where = "上街搭配"
    if(@user)
      @dapeis=Dapei.v_dapeis_by(@user).page(params[:page]).per(10)
      @number=@dapeis.count
      respond_to do |format|
        format.html
        format.json{render_for_api :dapei_list, :json=>@dapeis, :api_cache => 30.minutes, :meta=>{:result=>"0", :total_count=>@number.to_s}}
      end
    else
      respond_to do |format|
        format.html
        format.json{render :json=>{:result=>"1"}}
      end
    end
  end

  def favorite_dapeis
    @where = "喜欢搭配"
    only_like = false
    only_like = true if params[:like]
    if(@user)
      @number = Dapei.dapei_liked_by(@user).uniq.count
      @dapeis = Dapei.dapei_liked_by(@user).uniq.page(params[:page]).per(10)
      @liked_dapeis = Dapei.dapei_liked_by(@user).uniq.page(params[:page]).per(10)
        
 
      unless only_like 
        @created_number =   Dapei.dapeis_by(@user).count    
        @created_dapeis = Dapei.dapeis_by(@user).page(params[:page]).per(5)

        @dapeis = @created_dapeis + @dapeis
        @number = @created_number + @number
      end
      respond_to do |format|
        format.html
        format.json{render_for_api :dapei_list, :json=>@dapeis, :api_cache => 30.minutes, :meta=>{:result=>"0", :total_count=>@number.to_s}}
      end
    else
      respond_to do |format|
        format.html
        format.json{render :json=>{:result=>"1"}}
      end
    end
  end

 
  def favorite_collections
    if(@user)
      @number = Dapei.collection_liked_by(@user).uniq.count
      @collections = Dapei.collection_liked_by(@user).uniq.page(params[:page]).per(10)
      respond_to do |format|
        format.html
        format.json{render_for_api :collection_list, :json=>@collections, :api_cache => 30.minutes, :meta=>{:result=>"0", :total_count=>@number.to_s}}
      end
    else
      respond_to do |format|
        format.html
        format.json{render :json=>{:result=>"1"}}
      end
    end
  end

 
  def favorite_brands
    @where = "喜欢品牌"
    if(@user)
      @number=Brand.liked_by(@user).uniq.count
      @brands=Brand.liked_by(@user).uniq.page(params[:page]).per(10)
      respond_to do |format|
        format.html
        format.json{render_for_api :public, :json=>@brands, :api_cache => 30.minutes, :meta=>{:result=>"0", :total_count=>@number.to_s}}
      end
    else
      respond_to do |format|
        format.html
        format.json{render :json=>{:result=>"1"}}
      end
    end
  end


  def commented_items
    @where = "评论宝贝"
    if(@user)
      @number=Item.commented_by(@user).uniq.count
      @items=Item.commented_by(@user).uniq.page(params[:page]).per(10)
      respond_to do |format|
        format.html
        format.json{render_for_api :public, :json=>@items, :api_cache => 30.minutes,  :meta=>{:result=>"0", :total_count=>@number.to_s}}
      end
    else
      respond_to do |format|
        format.html
        format.json{render :json=>{:result=>"1"}}
      end
    end
  end

  def commented_shops
     @where = "评论店铺"
    @number= Shop.commented_by(@user).uniq.count
    @shops=Shop.commented_by(@user).uniq.page(params[:page]).per(10)
    respond_to do |format|
      format.html
      if @user
        format.json{render_for_api :public, :json=>@shops, :api_cache => 30.minutes,  :meta=>{:result=>"0", :total_count=>@number.to_s}}
      else
        format.json{render :json=>{:result=>"1"}}
      end
    end
  end

  def followings
    @where = "关注"
    if(@user)
      @number=@user.following_by_type('User').count
      @followings=@user.following_by_type('User').order("follows.created_at desc").page(params[:page]).per(10)
      respond_to do |format|
        format.html
        format.json{render_for_api :public, :json=>@followings, :api_cache => 30.minutes, :meta => {:result=>"0", :total_count =>@user.following_count.to_s } }
      end
    else
      respond_to do |format|
        format.html
        format.json{render :json=>{:result=>"1"}}
      end
    end
  end

  def followers
      @where = "粉丝"
    if (@user)
      @number=@user.followers_by_type('User').count
      @followers= @user.followers_by_type('User').order("follows.created_at desc").page(params[:page]).per(10)
      respond_to do |format|
        format.html
        format.json{render_for_api :public, :json=>@followers, :api_cache => 30.minutes, :meta => {:result=>"0", :total_count =>@user.followers_count.to_s } }
      end
    else
      respond_to do |format|
        format.html
        format.json{render :json=>{:result=>"1"}}
      end
    end
  end
  
  def update
    authorize! :update, @user, :message => 'Not authorized as an administrator.'
    #if @user.update_attributes(params[:user], :as => :admin)
    
    prev_level = @user.level.to_i
    if @user.update_attributes(params[:user])
      current_level = @user.level.to_i
      if prev_level == 1 and current_level >= 2
          PushNotification.push_review_daren(@user.id)
      end
      if params[:photo]
          photo = Photo.find_by_id(pramas[:photo])
          photo.target_id = @user.id
          photo.target_type = "User"
          photo.save!
      end

      redirect_to users_path, :notice => "User updated."
    else
      redirect_to users_path, :alert => "Unable to update user."
    end
  end

  def get_user_info
    respond_to do |format|
      #format.html
      if current_user
        format.json{render_for_api :public, :json=>current_user, :api_cache => 30.minutes, :meta=>{:result=>"0", :avatar_img_medium=>current_user.display_img_medium, :name=>current_user.name}}
      else
        format.json{render :json=>{:result=>"1"}}
      end
    end
  end
    
  def destroy
    authorize! :destroy, @user, :message => 'Not authorized as an administrator.'
    unless @user == current_user
      @user.destroy
      redirect_to users_path, :notice => "User deleted."
    else
      redirect_to users_path, :notice => "Can't delete yourself."
    end
  end

  
  def recommended
    @limit = 10
    @recommend_users = []
    if current_user
      user_following_ids = Follow.select(:followable_id).where(:followable_type => "User", :follower_id => current_user.id)
      unless user_following_ids
        user_following_ids = [0]
      else
        user_following_ids = user_following_ids.map(&:followable_id)
      end
      @recommend_users = User.where(["id not in (?)", user_following_ids]).order("dapei_score desc").limit(@limit)
    end
    
    if @recommend_users.length == 0  
      @recommend_users = User.where("apply_type >= 1").order("dapei_score desc").limit(@limit)
    end

    current_dapeis = Dapei.order('created_at desc').group('user_id').limit(@limit)  
    @current_users = current_dapeis.map{|dp|dp.get_user}

    @user_dict = {}
    @user_dict['recommend'] = @recommend_users.map{|u|u.to_dict}
    @user_dict['recommend_title'] = '推荐品牌'
    @user_dict['current'] = @current_users.map{|u|u.to_dict}
    @user_dict['current_title'] = '推荐达人'
    
    #@invite_dict = {}
    #@invite_dict['app_url'] = 'http://a.app.qq.com/o/simple.jsp?pkgname=com.shangjieba.client.android&g_f=991653'; 
    #@invite_dict['app_img'] = 'http://www.shangjieba.com/app_main_images/phone.png'
    #@invite_dict['invite_title'] = 'MAKE时尚'
    #@invite_dict['invite_text'] = '拍件衣服照片，大神马上帮你搭！超赞！'
    #@user_dict['invite'] = @invite_dict

    respond_to do |format|
      #format.html
      format.json{render :json=>@user_dict}
    end
  end
  

  def get_unread_count
    respond_to do |format|
      format.html
      if @user
        format.json{render :json=>{:result=>"0", :api_cache => 2.minutes, :unread_count=>@user.unread_notifications_count.to_s, :update_interval=>"10"}}
      else
        format.json{render :json=>{:result=>"1"}}
      end
    end
  end

  def auth_login
    auth = params[:auth]
    @user=nil
    @user=Authentication.find_from_hash_remote(auth)
    if(@user)
      respond_to do |format|
        format.html{
          #sign_in_and_redirect(:user, @user)
          redirect_to "/"
        }
        format.json {
          render_user_json
        }
      end
    else
      @username="dpms"+Devise.friendly_token[0,20]
      @email=@username+"@dapeimishu.com"
      @password=Devise.friendly_token[0,20]
      @authinfo={:name=>auth["name"], :email=>@email, :password=>@password, :remember_me=>1, :desc=>auth["description"],
        :profile_img_url=>auth["image_url"]}
      @user = User.new(@authinfo)
      if @user.save
        @user=Authentication.create_from_hash_remote(auth, @user)
        respond_to do |format|
          format.html{
            redirect_to "/"
          }
          format.json {
            render_user_json
          }
        end
      else
        respond_to do |format|
          format.html{redirect_to "/"}
          format.json {
            render :status => 200, :json => {:result=>"1"}
          }
        end
      end
    end
  end


  #2014-08-16 手机登陆 发送验证码
  def send_code
      mobile = params[:mobile].strip

      @is_new = 0
      @user = User.find_by_mobile(mobile)
      if @user.blank?

        @is_new = 1

        username="dpms"+Devise.friendly_token[0,20]
        email=username+"@dapeimishu.com"
        password=Devise.friendly_token[0,20]

        @user = User.new
        @user.email = email
        @user.name = username
        @user.password = password
        @user.remember_me = 1
        @user.mobile = mobile

        @user.save
      else
        logger.info "------------"
      end

      return @errors = 'timeout' if build_and_send_code[:code] != "0"
      render_state 'success'
  end

  def login_with_mobile
    mobile = params[:mobile].strip
    @user = User.find_by_mobile(mobile)

    unless @user.blank?
      if params[:code] == $redis.get(mobile)
        $redis.del(mobile)
        @user.mobile_verified(mobile)
        render_user_json
      else
        render :json => {error: "验证码错误"}
        return
      end
    else
      render :json => {error: "用户不存在"}
      return
    end
  end


  def verify_with_mobile
    mobile = params[:mobile].strip

    if current_user
      if params[:code] == $redis.get(mobile)
        $redis.del(mobile)
        current_user.mobile_verified(mobile)
        render :status => 200, :json => {:result=>"0",  :session => current_user.login_json }
      else
        render :json => {error: "验证码错误"}
        return
      end
    else
      render :json => {error: "用户不存在"}
      return
    end
  end

  private
  def get_user
    @user = User.find_by_url(params[:id])
  end

  def set_current
    User.current_user = current_user 
  end

  def build_and_send_code
    mobile = params[:mobile].strip
    @token = sprintf("%04d", rand(9999))
    $redis.set mobile, @token
    $redis.expire(mobile, 600)
    ChinaSMS.to(mobile, "注册验证码:#{@token} 【#{$app_name}】") 
 end

end
