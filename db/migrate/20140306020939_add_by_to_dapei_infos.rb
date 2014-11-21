# -*- encoding : utf-8 -*-
class AddByToDapeiInfos < ActiveRecord::Migration
  def change
    add_column :dapei_infos, :by, :string

  end
end
