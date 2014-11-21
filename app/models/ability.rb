# -*- encoding : utf-8 -*-
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    can :read, :all
    can [:new, :create], Comment
    can [:new, :create], Photo
    can [:new, :create, :like_users, :next, :prev], Post
    cannot [:new, :create], Recommend
    can :destroy, Comment do |comment|
       comment.user_id == user.id
    end
    can :destroy, Like do |like|
       like.user_id == user.id
    end
    can :destroy, Post do |post|
       post.user_id == user.id
    end
    
    can :destroy, Dapei do |dapei|
       dapei.user_id == user.id
    end
    
    can [:index_all, :shop_items, :shop_discounts,:search, :map_address, :create,  :recommended], Shop
    can :search_by_map, Shop
    can [:index_all, :like_users, :recommended_items, :warn_no_right, :new, :create, :next, :prev], Item
    can [:index_all, :recommended, :new, :create], Discount
    can [:warn_no_shop], :shop_admin
    can [:index, :view, :get_dp_items, :get_like_users], Dapei
    can [:brand_items], Brand
    can [:like_users], Brand
    can [:like_users], Sku  
    can [:ssq, :ssq_status], User
    can [:materials, :commit], Game

    cannot [:manage_items, :manage_discounts, :warn_one_shop, :success_pub_item, :success_pub_discount, :success_update_info, :success_open_shop], :shop_admin
    #cannot :read, Brand
    #cannot :read, Sku
    can :read, Brand
    can :read, BrandTag
    can :read, Lottery
    can :read, JoinLottery

    can :index, BrandTag
    can [:web_index, :web_show, :upload, :brand_tags], Brand
    can :read, Sku
    cannot :read, CrawlerTemplate
    can [:casperjs], Spider
    can [:create_sku], Spider
    can [:dislike], Like
    #cannot :index, :User
    #can :favorite_items, :User
    if user.can_be_admin
      #can :read, Brand
      #can :read, Sku
      can :read, CrawlerTemplate
      can :read, App
      can :read, AppInfo
      can :access, :rails_admin
      can :dashboard
      can :manage, :all
      can [:new, :admin_index, :test, :update, :create], Shop
      cannot :activate_shop, :all
      can :activate_shop, [Shop]
      can [:show, :manage_items, :manage_discounts, :warn_one_shop, :success_pub_item, :success_pub_discount, :success_update_info, :success_open_shop], :shop_admin
    elsif user.has_role? :shop_owner
      can [:update, :edit, :destroy], Shop do |shop|
         shop.user_id == user.id
      end
      #cannot [:new, :create], Shop
      can :manage, Item do |item|
         item.shop_id == user.shop.id
      end
      cannot [:recommend_item], Item
      can :manage, Discount do |discount|
         discount.discountable_id ==user.shop.id
      end
      cannot [:recommend_discount], Discount
      can [:show, :manage_items, :manage_discounts, :warn_one_shop, :success_pub_item, :success_pub_discount, :success_update_info, :success_open_shop], :shop_admin
    end
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
