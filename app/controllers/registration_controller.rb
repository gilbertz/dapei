# -*- encoding : utf-8 -*-
#encoding: utf-8
class RegistrationController <  Devise::RegistrationsController
  layout "new_app"
  #skip_before_filter :verify_authenticity_token

  def change_password
    #render :edit
  end

  def getting_started
    if current_user
      @user = current_user
      render :getting_started
      current_user.update_attributes(:getting_started => false)
    else
      redirect_to "/"
    end
  end

  def new
    super
  end

  def create
    #super
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        format.html { sign_in_and_redirect(:user, @user) }
        format.json { render_for_api :public, :json => @user, :meta=>{:result=>"0"} }
      else
        error_message=@user.errors.full_messages.join(' ')
        format.html { render :action => "new", :notice=>'用户创建失败!' }
        #format.json { render_for_api :error, :json => @user, :meta=>{:result=>"1"} }
        format.json{ render :status => 200, :json => {:error=>error_message} }
      end
    end
  end

  def update
    #super
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)

    if resource.update_with_password(resource_params)
      if is_navigational_format?
        if resource.respond_to?(:pending_reconfirmation?) && resource.pending_reconfirmation?
          flash_key = :update_needs_confirmation
        end
        set_flash_message :notice, flash_key || :updated
      end
      sign_in resource_name, resource, :bypass => true
      #respond_with resource, :location => after_update_path_for(resource)
    else
      clean_up_passwords resource
      #respond_with resource
    end

    #user = User.find_by_email( params[:user][:email] )
    #if params[:photo]
      #photo = Photo.find_by_id(params[:photo])
      #photo.target_id = user.id
      #photo.target_type = "User"
      #photo.save!
    #end  
     respond_to do |format|
      if @user.save
        if params[:avatar_image] and !Photo.correct_img_type?(params[:avatar_image_type])
           format.json { render :json=>{:result=>"1", :error=>"wrong format of image format"} }
        else
          Photo.build_user_avatar(current_user, params[:photo],params[:avatar_image], params[:avatar_image_type], @user.id, "User")
          if params[:bg_image] and params[:bg_image_type]
            bg_photo_id = Photo.build_avatar(current_user, params[:bg_image], params[:bg_image_type])
            @user.bg_photo_id = bg_photo_id
            @user.save
          end
          format.html { redirect_to (params[:start]=="1" ? root_path : user_path(current_user) ), notice: 'Post was successfully created.' }
          format.json { render_for_api :public, json: @user, :meta=>{:result=>"0", :avatar_img_medium=>@user.display_img_medium} }
        end
      else
        format.html { render action: "new" }
        format.json { render_for_api :error, json: @user, :meta=>{:result=>"1"} }
      end
    end
  end


end
