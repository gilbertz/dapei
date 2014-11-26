# -*- encoding : utf-8 -*-
class PasswordsController < Devise::PasswordsController
  layout false

  def update
    mobile = params[:mobile].strip

    if current_user
      if params[:code] == $redis.get(mobile)
        $redis.del(mobile)
        if current_user.update_attributes!(:password => params[:user][:password])
          render_state('success')
        else
          render :json => {error: "修改密码失败"}
        end
      else
        render :json => {error: "验证码错误"}
        return
      end
    else
      render :json => {error: "用户不存在"}
      return
    end
  end

end
