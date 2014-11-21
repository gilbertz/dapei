# -*- encoding : utf-8 -*-
#encoding: utf-8
class Manage::DapeiTagsController < Manage::BaseController
  before_filter :set_param_side

  def index
    @types = {0 => "风格", 1 => "主题", 2 => "款式", 3 => "色系", 4=>"元素", 5 => "身材"}
    @q = DapeiTag.ransack params[:q]
    @dapei_tags = @q.result.order('id desc').page(params[:page]).per(16)
  end

  def new
    @dapei_tag = DapeiTag.new
    @parent_tag = DapeiTag.get_parent_tags

    @users = []
    @users << @dapei_tag.get_user if @dapei_tag.get_user
    @users += User.system_users
    @users += User.where("id > 20000").limit(200)
    @users_for_select = @users.collect{|c| [c.name, c.id] }

    render partial: 'form'
  end

  def create
    @dapei_tag = DapeiTag.new params[:dapei_tag]
    @dapei_tag.save
    redirect_to [:manage,:dapei_tags]
  end

  def edit
    @dapei_tag = DapeiTag.find params[:id]

    @parent_tag = DapeiTag.get_parent_tags

    @users = []
    @users << @dapei_tag.get_user if @dapei_tag.get_user
    @users += User.system_users
    @users += User.where("id > 20000").limit(200)
    @users_for_select = @users.collect{|c| [c.name, c.id] }

    render partial: 'form'
  end

  def update
    @dapei_tag = DapeiTag.find params[:id]
    @dapei_tag.update_attributes params[:dapei_tag]
    redirect_to [:manage,:dapei_tags]
  end


  def upload
    require 'fileutils' #ruby老版本可尝试改为 require 'ftools'

    dir = ""
    tmp = nil
    field = nil

    tag_id = params[:id]
    tag = DapeiTag.find_by_id(tag_id)

    thing_id = "#{Time.now.to_i}"

    if tag
      if params[:logo_file]
        tmp = params[:logo_file]
        dir = "dapei_tags"
        tag.avatar_url = "http://qingchao1.qiniudn.com/uploads/#{dir}/#{thing_id}.png"
      end

      if params[:img_file]
        tmp = params[:img_file]
        dir = "dapei_tags"
        tag.img_url = "http://qingchao1.qiniudn.com/uploads/#{dir}/#{thing_id}.png"
      end 

      dir_path = "/var/www/shangjieba/public/uploads/#{dir}"
      FileUtils.mkdir_p(dir_path) unless Dir.exist?(dir_path)

      file = File.join("/var/www/shangjieba/public/uploads/#{dir}", "#{thing_id}.png")
      File.open(file, "wb") { |f| f.write tmp.read() }
      tag.save
      render json: {"image_url" => "http://qingchao1.qiniudn.com/uploads/#{dir}/#{thing_id}.png"}
    else
      render :text => "wrong"
    end

  end

  private
  def set_param_side
    @param_side = 'manage/matters/sidebar'
  end
end
