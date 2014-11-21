module Acme
  module V4
    class ApiBrand < Grape::API
      version 'v4', using: :path
      resources 'brand' do
        get "/list", jbuilder: 'V4/brand/list' do
          @user = User.find_by_authentication_token params[:token] if params[:token]
          # @user = User.first
          @brands = Brand.api_get_brands
          if @user
            @user_brand_tags = @user.brand_tags
          end
        end

        get 'real_list',jbuilder: 'V4/brand/real_list' do
          @user = User.find_by_authentication_token params[:token] if params[:token]
          # @user = User.first
          # @brands = Brand.api_get_brands
          if params[:limit].blank?
            params[:limit] = 5
          end
          if params[:page].blank?
            params[:page] = 1
          end
          @brands = Kaminari.paginate_array(Brand.api_get_all_brands)
                               .page(params[:page].to_i).per(params[:limit].to_i)
          #@brands = Brand.api_get_all_brands.page(params[:page].to_i).per(params[:limit].to_i)
          
          if @user
            @user_brand_tags = @user.brand_tags
          end
        end

        get "/info", jbuilder: 'V4/brand/info' do
          @user = User.find_by_authentication_token params[:token] if params[:token]
          @brand = Brand.find(params[:brand_id])
          if params[:limit].blank?
            params[:limit] = 8
          end
          if params[:page].blank?
            params[:page] = 1
          end
          @items = Item.tagged_with(@brand.display_name).where('level>=2 and category_id != 1000').uniq.page(params[:page].to_i).per(params[:limit].to_i)
        end
      end
    end
  end
end
