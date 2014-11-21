# -*- encoding : utf-8 -*-
class AddWeixinIdToUserExts < ActiveRecord::Migration
  def change
    add_column :user_exts, :weixin_id, :string

  end
end
