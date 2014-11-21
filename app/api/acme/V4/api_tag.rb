# encoding: utf-8
module Acme
  module V4
    class ApiTag < Grape::API
      version 'v4', using: :path
      resource 'tag' do
        get '/hot_tags', jbuilder: 'V4/tags/hot_tags' do
          @user = User.find_by_authentication_token params[:token] if params[:token]
          @hot_tags = Tag.item_hot_tags
          if @user
            @user_hot_tags = @user.get_ctags
          end
          @hot_tags = @user_hot_tags+@hot_tags
          @hot_tags=@hot_tags.uniq
        end

        get '/meta_tags', jbuilder: 'V4/tags/meta_tags' do
          @user = User.find_by_authentication_token params[:token] if params[:token]
          if params[:limit].blank?
            params[:limit] = 5
          end
          if params[:page].blank?
            params[:page] = 1
          end
          @meta_tag = MetaTag.find(params[:meta_id])
          @items = Item.where(params[:meta_id]).page(params[:page].to_i).per(params[:limit].to_i)
        end
      end
    end
  end
end
