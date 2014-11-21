namespace :log_analysis do

  task :go => :environment do

    yesterday = 1.day.ago.strftime("%Y-%m-%d")

    da = DataAnalysis.where(:which_day => yesterday).last

    if da.blank?
      da = DataAnalysis.new(:which_day => yesterday)
    end

    puts da.inspect

    yesterday_begin = 1.day.ago.strftime("%Y-%m-%d 00:00:01")
    yesterday_end = 1.day.ago.strftime("%Y-%m-%d 23:59:59")

    active_users = User.where("last_sign_in_at >= ? and last_sign_in_at <= ?", yesterday_begin, yesterday_end).count

    new_users_count = User.where("created_at >= ? and created_at <= ?", yesterday_begin, yesterday_end).count

    likes_count = Like.where("created_at >= ? and created_at <= ?", yesterday_begin, yesterday_end).count
    comments_count = Comment.where("created_at >= ? and created_at <= ?", yesterday_begin, yesterday_end).count
    skus_count = Sku.where("created_at >= ? and created_at <= ?", yesterday_begin, yesterday_end).count
    dapeis_count = Dapei.where("created_at >= ? and created_at <= ? and category_id = 1001", yesterday_begin, yesterday_end).count
    ask_counts = AskForDapei.where("created_at >= ? and created_at <= ?", yesterday_begin, yesterday_end).count

    #搭配点赞数量
    dapeis_likes_count = Like.where("created_at >= ? and created_at <= ? and target_type='Item'", yesterday_begin, yesterday_end).count
    dapeis_like_users_count = Like.where("created_at >= ? and created_at <= ? and target_type='Item'", yesterday_begin, yesterday_end).count("DISTINCT user_id")

    dapeis_comments_count = Comment.where("created_at >= ? and created_at <= ? and commentable_type='Item'", yesterday_begin, yesterday_end).count

    dapeis_comment_users_count = Comment.where("created_at >= ? and created_at <= ? and commentable_type='Item'", yesterday_begin, yesterday_end).count("DISTINCT user_id")

    new_dapeis_users_count = Item.where("category_id = 1001 and created_at >= ? and created_at <= ?", yesterday_begin, yesterday_end).count("DISTINCT user_id")

    ask_users_count = AskForDapei.where("created_at >= ? and created_at <= ?", yesterday_begin, yesterday_end).count("DISTINCT user_id")

    ask_answers_count = DapeiResponse.where("created_at >= ? and created_at <= ?", yesterday_begin, yesterday_end).count

    #问问回复的评论数
    ask_ding_count = Comment.where("created_at >= ? and created_at <= ? and commentable_type='DapeiResponse'", yesterday_begin, yesterday_end).count

    sku_like_users_count = Like.where("created_at >= ? and created_at <= ? and target_type='Sku'", yesterday_begin, yesterday_end).count("DISTINCT user_id")

    sku_likes_count = Like.where("created_at >= ? and created_at <= ? and target_type='Sku'", yesterday_begin, yesterday_end).count

    sku_comments_count = Comment.where("created_at >= ? and created_at <= ? and commentable_type='Sku'", yesterday_begin, yesterday_end).count

    sku_comment_users_count = Comment.where("created_at >= ? and created_at <= ? and commentable_type='Sku'", yesterday_begin, yesterday_end).count("DISTINCT user_id")

    collections_count = Dapei.where("created_at >= ? and created_at <= ? and category_id = 1000", yesterday_begin, yesterday_end).count

    collection_like_count =  Like.joins("left join items on likes.target_id = items.id and likes.target_type='Item'").where("likes.created_at >= ? and likes.created_at <= ? and target_type='Item' and items.category_id=1000", yesterday_begin, yesterday_end).count

    da.collections_count = collections_count
    da.dapeis_likes_count = dapeis_likes_count
    da.dapeis_like_users_count = dapeis_like_users_count
    da.dapeis_comments_count = dapeis_comments_count
    da.dapeis_comment_users_count = dapeis_comment_users_count
    da.new_dapeis_users_count = new_dapeis_users_count
    da.ask_users_count = ask_users_count
    da.ask_answers_count = ask_answers_count
    da.ask_ding_count = ask_ding_count
    da.sku_like_users_count = sku_like_users_count
    da.sku_likes_count = sku_likes_count
    da.sku_comments_count = sku_comments_count
    da.sku_comment_users_count = sku_comment_users_count

    da.active_users = active_users
    da.new_users_count = new_users_count
    da.likes_count = likes_count
    da.comments_count = comments_count
    da.skus_count = skus_count
    da.dapeis_count = dapeis_count
    da.ask_counts = ask_counts

    da.save
    puts da.inspect
  end

  task :log => :environment do

    #TODO
    #dapeis_view_users_count


    yesterday = 1.day.ago.strftime("%Y-%m-%d")

    da = DataAnalysis.where(:which_day => yesterday).last

    if da.blank?
      da = DataAnalysis.new(:which_day => yesterday)
    end

    file_name = "parsed_production#{yesterday.split('-').join}.txt"
    file_path = "/data/log/shangjieba/#{file_name}"

    unless File.exist?(file_path)
      return
    end

    my_hash = {
        "get_item_detail" => {column: "skus_view_count", count: 0},
        "dapeis/view" => {column: "dapeis_view_count", count: 0},
        "dapei_responses" => {column: "ask_view_count", count: 0},
        "dapeis/collections" => {column: "collection_view_count", count: 0}
    }

    File.open(file_path) do |file|

      file.each_line do |line|

        puts line
        puts "======================="

        if line.include?("json")
          my_hash.each_key do |k|

            puts "========key: #{k}==============="

            if line.include?(k)
              puts "=============GET it=================="
              my_hash[k][:count] += 1
              break
            end

          end
        end

      end

    end

    puts my_hash.inspect

    my_hash.each do |h|
      method_name = "#{h[1][:column]}="
      da.send(method_name, h[1][:count])
    end

    da.save

  end

end