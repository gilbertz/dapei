# -*- encoding : utf-8 -*-
class AddDateToDapeiInfos < ActiveRecord::Migration
  def change
    add_column :dapei_infos, :start_date, :date

    add_column :dapei_infos, :end_date_date, :string

  end
end
