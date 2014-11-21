# -*- encoding : utf-8 -*-
class Manage::UserBehavioursController < Manage::BaseController
  before_filter :set_param_side
  def initialize
    @sphinx_xml = Sphinx::Client.new()
    @sphinx_xml.SetServer("114.80.100.12", 9319)  
  end

  def index
    @user_id = params[:user_id]
    if @user_id
      @user = User.find(@user_id)
      @user_behaviours = @user.user_behaviours.order{request_time.desc}.page(params[:page]).per(50)
    else
      @q = User.ransack params[:q]
      @users = @q.result.order("last_sign_in_at desc").page(params[:page]).per(25)
    end
    render :layout=>"manage/layouts/manage"
  end

  def xml_index 
    @user_token = params[:user_token]
    if @user_token
      @user = User.find(@user_token)

      @sphinx_xml.ResetFilters()
      @sphinx_xml.SetLimits(0,10000,20000)
      search_results = @sphinx_xml.Query(@user.authentication_token, "user_behaviours")
      new_xml_docs = []
      search_results["matches"].uniq.each do |xml_doc|
        xml_doc_hash = xml_doc["attrs"].symbolize_keys
        new_xml_docs << xml_doc_hash if !new_xml_docs.include?(xml_doc_hash)
      end
      user_behaviours = new_xml_docs.sort_by{|xml_doc| xml_doc[:request_time]}.reverse
      current_page = params[:page] || 1
      @user_behaviours = WillPaginate::Collection.create(current_page, 50, user_behaviours.length) do |pager|
        pager.replace user_behaviours.slice(pager.offset, pager.per_page)
      end
    end
    render :layout=>"manage/layouts/manage"
  end

  private
  def set_param_side
    params[:side] = 'manage/areas/sidebar'
  end
end
