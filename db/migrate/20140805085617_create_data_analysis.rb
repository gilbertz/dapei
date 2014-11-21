# -*- encoding : utf-8 -*-
class CreateDataAnalysis < ActiveRecord::Migration
  def up
    create_table :data_analyses do |t|

      t.integer :active_users, :default => 0
      t.integer :login_users, :default => 0
      t.integer :new_users_count


      t.integer :qq_login_users, :default => 0
      t.integer :weibo_login_users, :default => 0

      t.integer :likes_count
      t.integer :comments_count
      t.integer :skus_count

      t.integer :dapeis_count

      t.integer :ask_counts

      t.integer :dapeis_view_count
      t.integer :skus_view_count
      t.integer :ask_view_count

      t.date :which_day

      t.timestamps

    end
  end

  def down
    drop_table :data_analyses
  end
end
