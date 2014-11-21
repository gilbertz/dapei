# -*- encoding : utf-8 -*-
class Manage::FlowersController < Manage::BaseController


  def index
    #@flowers = Flower.where(:is_lucky => 1).order("id desc")

    begin_at = Time.now.strftime("%Y-%m-%d 03:30:00")


    unless params[:t].blank?
      tmp_time = Time.new(Time.now.year, Time.now.month, Time.now.day, 03, 30)

      end_at = (tmp_time + params[:t].to_i.seconds).strftime("%Y-%m-%d %H:%M:%S")
    else
      end_at = Time.now.strftime("%Y-%m-%d 05:00:00")
    end

    @likes = Like.where("created_at >= '#{begin_at}' and created_at <= '#{end_at}' and target_type = 'Item'").order("count_all desc").count(:group => :user_id).first(200)

    lids = @likes.collect{|l| l[0] }

    @uids = {}

    @likes.each do |l|
      @uids[l[0]] = l[1]
    end

    @like_count_users = LikeCountUser.where("created_at >= '#{begin_at}' and created_at <= '#{end_at}'").order("id asc").group(:user_id).first(60)

  end

  def home

    con = "1=1 and flowers.created_at >= 2014-06-25"

    unless params[:name].blank?
      con += " and (users.name like '%#{params[:name]}%' or users.nickname like '%#{params[:name]}%')"
    end

    unless params[:is_lucky].blank?
      con += " and flowers.is_lucky = #{params[:is_lucky].to_i - 1}"
    end

    @flowers = Flower.joins("left join users on flowers.user_id = users.id").where(con).where("flowers.created_at >= ?", 24.hours.ago).order("flowers.id desc").paginate(:page => params[:page])

  end

end
