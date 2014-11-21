# -*- encoding : utf-8 -*-
#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class LikesController < ApplicationController
  before_filter :authenticate_user!, :only=>[:new, :create, :destroy, :dislike]
  load_and_authorize_resource :except => [:create, :new]
  skip_before_filter :verify_authenticity_token, :only => [:create, :dislike]

  respond_to :html,
             :json

  def create
    unless params[:request].blank?
      pr = JSON.parse(params[:request])
      
      tid = pr["tid"]

      matter = Matter.find_by_image_name(tid)

      params[:like] = {:target_type => "Matter", :target_id => matter.id}

    end
    if(params[:like][:target_type]=="Post" or params[:like][:target_type]=="DapeiResponse" or params[:like][:target_type]=="Sku" or params[:like][:target_type]=="Discount" or params[:like][:target_type]=="Brand" or  params[:like][:target_type]=="Matter")
      @target_id=params[:like][:target_id].to_i
    else
      @target_type=params[:like][:target_type].constantize 
      inst = @target_type.find_by_url(params[:like][:target_id])
      if inst
        @target_id = inst.id
      elsif params[:like][:target_type] == "Item"
        if Sku.find_by_id(params[:like][:target_id])
          params[:like][:target_type] = "Sku"
          @target_type = params[:like][:target_type].capitalize.constantize
          @target_id = params[:like][:target_id].to_i
        elsif Item.by_url( params[:like][:target_id] )
          @target_type = params[:like][:target_type].capitalize.constantize
          @target_id = params[:like][:target_id].split('@')[0]
        end
      end
    end
    if not @target_id
       format.html { render :nothing => true, :status => 422 }
       format.json { render_for_api :error, :json=>@like, :meta=>{:result=>"1"} } 
    end

    if Like.has_liked? current_user.id, @target_id, params[:like][:target_type]
      respond_to do |format|
        format.html { render :nothing => true }
        format.json { render :json => {:result=>"1", :error=>"You have already liked it."} }
      end
    else
      @target_type=params[:like][:target_type].constantize
      @likeable = @target_type.find(@target_id)
      
      if not @likeable
        format.html { render :nothing => true, :status => 422 }
        format.json { render_for_api :error, :json=>@like, :meta=>{:result=>"1"} }
      else
        @like = @likeable.likes.new({:target_type=>params[:like][:target_type], :target_id=>@target_id, :user_id=>current_user.id})
        if @like.save
          #like sku also like matter
          if params[:like][:target_type] == 'Sku'
            @likeable.make_matter
          end

          respond_to do |format|
            format.html { render :nothing => true, :status => 201 }
            format.json { render_for_api :public, :json=>@like, :meta=>{:result=>"0"} }
          end
        else
          format.html { render :nothing => true, :status => 422 }
          format.json { render_for_api :error, :json=>@like, :meta=>{:result=>"1"} }
        end
      end
    end
  end

  def destroy
    @like = Like.find_by_id_and_user_id!(params[:id], current_user.id)
    if @like
      @like.destroy
      respond_to do |format|
        format.html { redirect_to :back }
        format.json { render :json=>{:result=>"0"} }
      end
    else
      respond_to do |format|
        format.html { redirect_to :back }
        format.json { render :json=>{:result=>"1"} }
      end
    end
  end

  def dislike
    if params[:target_type] and params[:target_id]
      if params[:target_type] == "Item" or params[:target_type]  == "Dapei"
         target = Item.find_by_url(params[:target_id])
         params[:target_id] = target.id if target
      end
      @like = Like.find_by_user_id_and_target_id_and_target_type(current_user.id, params[:target_id], params[:target_type])
    end
    if @like
      @like.destroy
      respond_to do |format|
        format.html { redirect_to :back }
        format.json { render :json=>{:result=>"0"} }
      end
    else
      respond_to do |format|
        format.html { redirect_to :back }
        format.json { render :json=>{:result=>"1"} }
      end
    end
  end


protected

  #def target
  #  @target ||= if params[:shop_id]
  #    Shop.find_by_id(params[:shop_id])
  #  elsif params[:item_id]
  #    Item.find_by_id(params[:item_id])
  #  elsif params[:discount_id]
  #    Discount.find_by_id(params[:discount_id])
  #  elsif params[:post_id]
  #    Post.find_by_id(params[:post_id]) || raise(ActiveRecord::RecordNotFound.new)
  #  elsif params[:comment_id]
  #    Comment.find_by_id(params[:comment_id])
  #  else
  #  end
  #end
end
