# -*- encoding : utf-8 -*-
class Monitor::WelcomeController < Monitor::MonitorController


  def home
    limit = 7

    unless params[:limit].blank?
      limit = params[:limit].to_i
    end

    # :dapeis_view_count => "搭配查看",
    # :skus_view_count => "sku查看",
    # :ask_view_count => "问问查看"

    @data_analyses = DataAnalysis.order("id desc").limit(limit).reverse
    @limit_days = @data_analyses.collect{|d| d.which_day.strftime("%Y-%m-%d") }

    @all = {
        :active_users => "活跃用户",
        :new_users_count => "新注册用户",
        :likes_count => "喜欢",
        :comments_count => "评论",
        :skus_count => "SKU",
        :ask_counts => "问问"
    }
    @show_names = []
    @series = []
    @all.each do |key, value|
      @show_names << value
      tmp_data = @data_analyses.collect{|d| d.send(key).to_i }
      tmp_all = {name: value, type: "line", stack: "总量", data: tmp_data}
      @series << tmp_all
    end

    @all2 = {
        :dapeis_likes_count => "搭配喜欢数",
        :dapeis_count => "搭配",
        :dapeis_comments_count => "搭配评论数",
        :dapeis_like_users_count => "搭配喜欢用户数",
        :dapeis_comment_users_count => "搭配评论用户数",
        :dapeis_view_users_count => "搭配查看用户",
        :new_dapeis_users_count => "新建搭配用户",
        :dapeis_view_count => "搭配查看"
    }
    @show_names2 = []
    @series2 = []
    @all2.each do |key, value|
      @show_names2 << value
      tmp_data = @data_analyses.collect{|d| d.send(key).to_i }
      tmp_all = {name: value, type: "line", data: tmp_data}
      @series2 << tmp_all
    end

    @all3 = {
        :sku_likes_count => "SKU喜欢数",
        :skus_count => "SKU",
        :sku_comments_count => "SKU评论数",
        :sku_like_users_count => "SKU喜欢用户数",
        :sku_comment_users_count => "SKU评论用户数",
        :skus_view_count => "SKU查看"
    }
    @show_names3 = []
    @series3 = []
    @all3.each do |key, value|
      @show_names3 << value
      tmp_data = @data_analyses.collect{|d| d.send(key).to_i }
      tmp_all = {name: value, type: "line", data: tmp_data}
      @series3 << tmp_all
    end

    @all6 = {
        :sku_likes_count => "SKU喜欢数/用户",
        :skus_count => "SKU/用户",
        :sku_comments_count => "SKU评论数/用户",
        :sku_like_users_count => "SKU喜欢用户数/用户",
        :sku_comment_users_count => "SKU评论用户数/用户",
        :skus_view_count => "SKU查看/用户"
    }
    @show_names6 = []
    @series6 = []
    @all6.each do |key, value|
      @show_names6 << value
      tmp_data = @data_analyses.collect{|d| (d.send(key).to_f / d.send(:active_users)).round(7)*1000 }
      tmp_all = {name: value, type: "line", data: tmp_data}
      @series6 << tmp_all
    end

    @all4 = {
        :likes_count => "喜欢/活跃用户",
        :comments_count => "评论/活跃用户"
    }
    @show_names4 = []
    @series4 = []
    @all4.each do |key, value|
      @show_names4 << value
      tmp_data = @data_analyses.collect{|d| (d.send(key).to_f / d.send(:active_users)).round(7)*1000 }
      tmp_all = {name: value, type: "line", data: tmp_data}
      @series4 << tmp_all
    end

    @all5 = {
        :ask_view_count => "问问查看",
        :ask_users_count => "问问人数",
        :ask_answers_count => "回答数"
    }
    @show_names5 = []
    @series5 = []
    @all5.each do |key, value|
      @show_names5 << value
      tmp_data = @data_analyses.collect{|d| (d.send(key).to_f / d.send(:active_users)).round(7)*1000 }
      tmp_all = {name: value, type: "line", data: tmp_data}
      @series5 << tmp_all
    end

    @all7 = {
        :collection_view_count => "选集查看",
        :collections_count => "选集",
        :collection_view_users_count => "选集查看人数",
        :collections_items_count => "选集单品",
        :collection_like_count => "喜欢"
    }
    @show_names7 = []
    @series7 = []
    @all7.each do |key, value|
      @show_names7 << value
      tmp_data = @data_analyses.collect{|d| d.send(key).to_i }
      tmp_all = {name: value, type: "line", data: tmp_data}
      @series7 << tmp_all
    end

    @all8 = {
        :collection_view_count => "选集查看/人",
        :collections_count => "选集/人",
        :collection_view_users_count => "选集查看人数/人",
        :collections_items_count => "选集单品/人",
        :collection_like_count => "喜欢/人"
    }
    @show_names8 = []
    @series8 = []
    @all8.each do |key, value|
      @show_names8 << value
      tmp_data = @data_analyses.collect{|d| (d.send(key).to_f / d.send(:active_users)).round(7)*1000 }
      tmp_all = {name: value, type: "line", data: tmp_data}
      @series8 << tmp_all
    end



    render :layout => false
  end

  caches_page :index
  def index
    hours_24_ago = Time.now - 24.hours
    days_12_ago = Time.now - 12.days

    #@users_count_total = User.count

    @redirect_12_day = RedirectRecord.where("created_at >= ?", days_12_ago).count(:group => "date_format(created_at, '%Y-%m-%d')")

    @shangpin_12_day = RedirectRecord.joins("left join skus on skus.id = redirect_records.sku_id").where("skus.buy_url like '%shangpin.com%'").where("redirect_records.created_at >= ?", days_12_ago).count(:group => "date_format(redirect_records.created_at, '%Y-%m-%d')")

    @tmall_12_day = RedirectRecord.joins("left join skus on skus.id = redirect_records.sku_id").where("skus.buy_url like '%tmall.com%'").where("redirect_records.created_at >= ?", days_12_ago).count(:group => "date_format(redirect_records.created_at, '%Y-%m-%d')")

    @yintai_12_day = RedirectRecord.joins("left join skus on skus.id = redirect_records.sku_id").where("skus.buy_url like '%yintai.com%'").where("redirect_records.created_at >= ?", days_12_ago).count(:group => "date_format(redirect_records.created_at, '%Y-%m-%d')")



    @redirect_24_hours = RedirectRecord.where("created_at >= ?", hours_24_ago).count(:group => "date_format(created_at, '%Y-%m-%d')")

    @shangpin_24_hours = RedirectRecord.joins("left join skus on skus.id = redirect_records.sku_id").where("skus.buy_url like '%shangpin.com%'").where("redirect_records.created_at >= ?", hours_24_ago).count(:group => "date_format(redirect_records.created_at, '%Y-%m-%d')")

    @tmall_24_hours = RedirectRecord.joins("left join skus on skus.id = redirect_records.sku_id").where("skus.buy_url like '%tmall.com%'").where("redirect_records.created_at >= ?", hours_24_ago).count(:group => "date_format(redirect_records.created_at, '%Y-%m-%d')")

    @yintai_24_hours = RedirectRecord.joins("left join skus on skus.id = redirect_records.sku_id").where("skus.buy_url like '%yintai.com%'").where("redirect_records.created_at >= ?", hours_24_ago).count(:group => "date_format(redirect_records.created_at, '%Y-%m-%d')")

    @stylosophy_24_hours = RedirectRecord.joins("left join skus on skus.id = redirect_records.sku_id").where("skus.buy_url like '%stylosophy.tmall.com%'").where("redirect_records.created_at >= ?", hours_24_ago).count(:group => "date_format(redirect_records.created_at, '%Y-%m-%d')")

    @lshop_24_hours = RedirectRecord.joins("left join skus on skus.id = redirect_records.sku_id").where("skus.buy_url like '%elleshop.com%'").where("redirect_records.created_at >= ?", hours_24_ago).count(:group => "date_format(redirect_records.created_at, '%Y-%m-%d')")


    # @dapeis_12_day = Item.where("created_at >= ?", days_12_ago).count(:group => "date_format(created_at, '%Y-%m-%d')")
    # @skus_12_day = Sku.where("created_at >= ?", days_12_ago).count(:group => "date_format(created_at, '%Y-%m-%d')")
    # @discounts_12_day = Discount.where("created_at >= ?", days_12_ago).count(:group => "date_format(created_at, '%Y-%m-%d')")
    # @shops_12_day = Shop.where("created_at >= ?", days_12_ago).count(:group => "date_format(created_at, '%Y-%m-%d')")
    # @active_users_12_day = User.where("current_sign_in_at >= ?", days_12_ago).count(:group => "date_format(created_at, '%Y-%m-%d')")
    #
    # @likes_12_day = Like.where("created_at >= ?", days_12_ago).count(:group => "date_format(created_at, '%Y-%m-%d')")
    # @comments_12_day = Comment.where("created_at >= ?", days_12_ago).count(:group => "date_format(created_at, '%Y-%m-%d')")

    @keys_label = @redirect_12_day.keys.collect{|k| k.to_time.strftime("%Y-%m-%d")}

    @redirect_12_day = format_value_by_mode(@redirect_12_day, @keys_label)
    @shangpin_12_day = format_value_by_mode(@shangpin_12_day, @keys_label)
    @tmall_12_day = format_value_by_mode(@tmall_12_day, @keys_label)
    @yintai_12_day = format_value_by_mode(@yintai_12_day, @keys_label)
    # @dapeis_12_day = format_value_by_mode(@dapeis_12_day, @keys_label)
    # @skus_12_day = format_value_by_mode(@skus_12_day, @keys_label)
    # @discounts_12_day = format_value_by_mode(@discounts_12_day, @keys_label)
    # @shops_12_day = format_value_by_mode(@shops_12_day, @keys_label)
    # @active_users_12_day = format_value_by_mode(@active_users_12_day, @keys_label)
    # @likes_12_day = format_value_by_mode(@likes_12_day, @keys_label)
    # @comments_12_day = format_value_by_mode(@comments_12_day, @keys_label)


    # @dapeis_users = Dapei.order("count_all desc").where("created_at >= '2014-04-23 00:00:01'").count(:group => "user_id").to_hash.first(30)
    #
    # du_ids = @dapeis_users.collect{|du| du[0] }
    #
    # @dus = User.where(:id => du_ids).all
    #
    #
    # @likes_users = ActiveRecord::Base.connection.execute("select `a`.`user_id` from (select `items`.`user_id`, sum(`likes_count`.`count_all`) as all_count from items right join (select `likes`.`target_id`, count(*) as count_all from likes where `likes`.`target_type` = 'Item' and `likes`.`created_at` > '2014-04-23 00:00:01' group by target_id) as likes_count on `items`.`id` = `likes_count`.`target_id` group by `items`.`user_id`) as a where a.all_count >= 5 order by all_count desc limit 30")
    #
    # lu_ids = @likes_users.collect{|lu| lu[0] }
    #
    # @lus = User.where(:id => lu_ids).all

    #"select `items`.`user_id` from (select `items`.`user_id`, sum(`likes_count`.`count_all`) as all_count from items right join (select `likes`.`target_id`, count(*) as count_all from likes where `likes`.`target_type` = 'Item' and `likes`.`created_at` > '2014-04-23 00:00:01' group by target_id) as likes_count on `items`.`id` = `likes_count`.`target_id` group by `items`.`user_id`) as a where a.all_count >= 5 order by all_count desc limit 20"

  end


  def expire_index
    expire_page "/monitor"
    redirect_to "/monitor"
  end

  private
  def format_value_by_mode(data, keys)

    new_data = []

    unless data.blank?

      keys.each do |k|

        if data.keys.include?(k)
          new_data << data[k]
        else
          new_data << 0
        end

      end

    end

    return new_data
  end

end
