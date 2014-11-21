# -*- encoding : utf-8 -*-
require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
module RailsAdminManageUser
end
module RailsAdmin
  module Config
    module Actions
      class ActivateShop < RailsAdmin::Config::Actions::Base
   

        register_instance_option :member? do  
          true 
        end

        register_instance_option :visible? do
          authorized?&&!bindings[:object].activated
        end

        register_instance_option :link_icon do
          'icon-check'
        end 
        
        register_instance_option :controller do          
          Proc.new do
            @object.update_attribute(:activated, true)
            flash[:notice] = "你已经激活了店铺: #{@object.name}"
            redirect_to back_or_index
            #link_to "ManageUser", "users"
          end
        end  

         register_instance_option :i18n_key do
           key        
         end

         register_instance_option :custom_key do
           key
         end      


      end
    end
  end
end
