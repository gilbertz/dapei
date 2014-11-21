# -*- encoding : utf-8 -*-
class SessionsController <  Devise::SessionsController
  layout "new_app"
  def create

    cookies[:l] = { :value => "#{Time.now.to_i}", :expires => 10.year.from_now }
    cookies[:userid] = { :value => "#{current_user.url}", :expires => 10.year.from_now } if current_user

    respond_to do |format|
      format.html { 
        super
      }
      format.xml {
        warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
        render :status => 200, :xml => { :session => { :error => 0, :token => current_user.authentication_token }}
      }
 
      format.json {
        warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
        render :status => 200, :json => {:result=>"0",  :session => current_user.login_json  }
      }
    end
  end

  def layer_create
    respond_to do |format|
      format.html { 
        render "layer_create", :layout=>false
      }
      format.xml {
        warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
        render :status => 200, :xml => { :session => { :error => 0, :token => current_user.authentication_token }}
      }

      format.json {
        warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
        render :status => 200, :json => {:result=>"0",  :session => current_user.login_json  }
      }
    end
  end
 
  def destroy
    respond_to do |format|
      format.html { super }
      format.xml {
        warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
        current_user.authentication_token = nil
        render :xml => {}.to_xml, :status => :ok
      }
 
      format.json {
        warden.authenticate!(:scope => resource_name, :recall => "#{controller_path}#new")
        current_user.authentication_token = nil
        render :json => {:result=>"0"}, :status => :ok
      }
    end
  end
end
