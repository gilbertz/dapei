# -*- encoding : utf-8 -*-
require 'rails_admin/config/actions'
require 'rails_admin/config/actions/base'
module RailsAdminManageUser
end
module RailsAdmin
  module Config
    module Actions
      class ManageUser < RailsAdmin::Config::Actions::Base


        register_instance_option :root? do
          true
        end

        register_instance_option :controller do
          Proc.new do
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
