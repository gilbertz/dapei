# -*- encoding : utf-8 -*-
class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true
  
  scopify

  SUPER_ADMIN       = 'super_admin'
  ADMIN             = 'admin'
  SHOP_OWNER        = 'shop_owner'
  SHOP_OWNER_DELETE = 'shop_owner_delete'

  ROLES = [ SUPER_ADMIN,
            ADMIN,
            SHOP_OWNER,
            SHOP_OWNER_DELETE]


  SUPER_ADMIN_ID      = 1
  ADMIN_ID            = 2
  SHOP_OWNER_ID       = 3
  SHOP_OWNER_DELETE_ID =4

  private

    def self.find_role_id(id)
      Rails.cache.fetch("role-#{id}") do #, :expires_in => 30.minutes
        self.find(id)
      end
    end

    def self.find_role_name(name)
      Rails.cache.fetch("role-#{name}") do #, :expires_in => 30.minutes
        self.find_by_name(name)
      end
    end

end
