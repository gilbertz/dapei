module Acme
  module V4
    class ApiHome < Grape::API
      version 'v4', using: :path
      # app 首页
      resource 'home' do
        get 'dapeis', jbuilder: 'V4/home/dapeis' do # 精选 最新 api 数据
          # token, limit,type ,page
          # type=hot 精选 =new 热门
          @updated_count = 0
          params[:limit] ||= 5
          current_user = User.find_by_authentication_token(params[:token])
          User.current_user = current_user if current_user 

          # @last_dapei = Item.where("level >= 2").order("updated_at desc").first
          # @all_items =  Item.v4_api_choiceness
          #@items =  Item.v4_api_choiceness.where("deleted is null and dapei_info_flag is null").page(params[:page]).per(params[:limit])
          @items =  Item.v4_api_choiceness.page(params[:page]).per(params[:limit])
          # @count = Item.v4_api_choiceness.size

        end

        get 'new', jbuilder: 'V4/home/dapeis' do
          current_user = User.find_by_authentication_token(params[:token])
          User.current_user = current_user if current_user
          @items =  Item.v4_api_new.where("deleted is null and dapei_info_flag is null").page(params[:page].to_i).per(params[:limit].to_i)
        end
       
        get 'follow', jbuilder: 'V4/home/dapeis' do
          current_user = User.find_by_authentication_token(params[:token])
          if current_user
            User.current_user = current_user if current_user
            @items =  Item.v4_api_follow(current_user.id).where("deleted is null and dapei_info_flag is null").page(params[:page]).per(params[:limit])
          else
            @items
          end
          # User.current_user = current_user if current_user
          # @items =  Item.v4_api_follow(current_user.id).page(params[:page]).per(params[:limit])
        end

        get 'tagged', jbuilder: 'V4/home/dapeis' do
          @current_user = User.find_by_authentication_token(params[:token])
          User.current_user = @current_user if @current_user 
          @brand =  Brand.find_by_display_name(params[:tag])
          @items =  Item.v4_api_tagged(params[:tag]).where("deleted is null and dapei_info_flag is null").page(params[:page].to_i).per(params[:limit].to_i)
          puts @items
        end


        get 'liked', jbuilder: 'V4/home/dapeis' do
          current_user = User.find_by_authentication_token(params[:token])
          User.current_user = current_user if current_user
          u = User.find_by_url params[:user_id]
          if u
            @items =  Item.v4_api_liked_by(u.id).where("deleted is null and dapei_info_flag is null").page(params[:page]).per(params[:limit])
          else
            @items 
          end
        end  

        get 'created', jbuilder: 'V4/home/dapeis' do
          current_user = User.find_by_authentication_token(params[:token])
          User.current_user = current_user if current_user
          u = User.find_by_url params[:user_id]
          if u
            @items =  Item.v4_api_created_by(u.id).where("deleted is null and dapei_info_flag is null").page(params[:page]).per(params[:limit])
          else
            @items 
          end
        end  

        get 'metatags_and_themes',jbuilder: 'V4/home/metatags_and_themes' do

          current_user = User.find_by_authentication_token(params[:token])
          User.current_user = current_user if current_user 

          @default_url = "http://g.shangjieba.com/home/list?game_type_id=3&fr=ios"
          @meta_tags = MetaTag.all
          @page = 1
          @page = params[:page].to_i if params[:page]
          @limit = 4
          @limit = params[:limit].to_i if params[:limit]
          @main_tags = DapeiTag.where( :parent_id => 99 ).where( :is_hot => true ).order("created_at desc").page(@page).per(@limit)
        end

        get 'deleted',jbuilder: 'V4/home/deleted.jbuilder' do

          current_user = User.find_by_authentication_token(params[:token])
          @result = 0
          if params[:id]
            Item.v4_api_deleted(params[:id])
          else
            @result = 1
          end
        end
      end
    end
  end
end
