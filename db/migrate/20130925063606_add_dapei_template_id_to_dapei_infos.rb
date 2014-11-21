# -*- encoding : utf-8 -*-
class AddDapeiTemplateIdToDapeiInfos < ActiveRecord::Migration
  def change
    add_column :dapei_infos, :dapei_template_id, :integer
  end
end
