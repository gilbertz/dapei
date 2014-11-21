# encoding: utf-8
module Acme
  module V4
    class ApiSelfie < Grape::API
      version 'v4', using: :path
      resource 'selfie' do
        post '/create', jbuilder: 'V4/selfie/create' do
          @user = User.find_by_authentication_token params[:token]
          selfie_params = body_parasm
          # p "#{params}"
          @selfie = Selfie.new
          if @user
            @selfie.user = @user
          else
            @selfie.user = User.find_by_id(1)
          end
         
          @selfie.api_publish(selfie_params)
        end

        get '/info', jbuilder: 'V4/selfie/view' do
          @selfie = Selfie.find(params[:id])
        end
      end
    end
  end
end