# -*- encoding : utf-8 -*-
class AddcolumnsToDataAnalyses < ActiveRecord::Migration
  def up
    add_column :data_analyses, :dapeis_likes_count, :integer, :default => 0
    add_column :data_analyses, :dapeis_comments_count, :integer, :default => 0
    add_column :data_analyses, :dapeis_like_users_count, :integer, :default => 0
    add_column :data_analyses, :dapeis_comment_users_count, :integer, :default => 0

    #查看搭配的人数
    add_column :data_analyses, :dapeis_view_users_count, :integer, :default => 0

    #发布搭配的用户数
    add_column :data_analyses, :new_dapeis_users_count, :integer, :default => 0

    #发布问问的用户数
    add_column :data_analyses, :ask_users_count, :integer, :default => 0

    add_column :data_analyses, :ask_answers_count, :integer, :default => 0

    add_column :data_analyses, :ask_ding_count, :integer, :default => 0

    add_column :data_analyses, :sku_like_users_count, :integer, :default => 0

    add_column :data_analyses, :sku_likes_count, :integer, :default => 0

    add_column :data_analyses, :sku_comments_count, :integer, :default => 0

    add_column :data_analyses, :sku_comment_users_count, :integer, :default => 0

    add_column :data_analyses, :collections_count, :integer, :default => 0

    add_column :data_analyses, :collection_view_count, :integer, :default => 0

    add_column :data_analyses, :collection_view_users_count, :integer, :default => 0

    add_column :data_analyses, :collections_items_count, :integer, :default => 0
  end

  def down
  end
end
