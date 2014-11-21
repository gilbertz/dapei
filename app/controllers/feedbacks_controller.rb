# -*- encoding : utf-8 -*-
class FeedbacksController < ApplicationController

  def create
    feedback = Feedback.new
    feedback.content = params[:content]
    feedback.qq = params[:qq]
    feedback.email = params[:email]
    feedback.telephone = params[:telephone]
    feedback.user_id = current_user.id if current_user

    respond_to do |format|
      if feedback.save
        format.js
        format.json { render :status => "ok", :json => {:result=>"0" } }
      else
        format.json { render :status => "failed", :json => {:result=>"1" } }
      end
    end
  end

end
