# -*- encoding : utf-8 -*-
class AddCommentToDapeiInfo < ActiveRecord::Migration
  def change
    add_column :dapei_infos, :comment, :text
  end
end
