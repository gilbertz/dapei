# -*- encoding : utf-8 -*-
#encoding: utf-8
class Manage::FeedbacksController < Manage::BaseController

  def index
    params[:side] = 'manage/areas/sidebar'
    @feedbacks = Feedback.order("created_at desc")
  end

  def edit
    @feedback = Feedback.find params[:id]
    render partial: 'form'
  end

  def update
    feedback = Feedback.find(params[:id])
    feedback.update_attributes(params[:feedback])
    feedback.save
    redirect_to manage_feedbacks_path
  end

  def new
    @feedback = Feedback.new
    render partial: "form"
  end

  def create
    feedback = Feedback.new(params[:feedback])
    feedback.save
    redirect_to manage_feedbacks_path
  end


end
