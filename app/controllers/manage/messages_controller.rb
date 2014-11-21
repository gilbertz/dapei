# -*- encoding : utf-8 -*-
class Manage::MessagesController < Manage::BaseController


  def new
    @user = User.find(params[:user_id])

    @message = Message.new(:accept_id => @user.id)

    @history_messages = Message.where(:accept_id => @user.id).all

    @users_for_sender_selected = User.system_users.collect{|u| [u.name, u.id] }
  end

  def create
    @message = Message.new(params[:message])
    @message.save
    redirect_to manage_users_path, notice: "消息发送成功！"
  end

  def destroy
    m = Message.find(params[:id])
    m.destroy
    redirect_to new_manage_user_message_path(m.accept_id)
  end

end
