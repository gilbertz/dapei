# -*- encoding : utf-8 -*-
class AddEndDateToDapeiInfos < ActiveRecord::Migration
  def change
    add_column :dapei_infos, :end_date, :date

  end
end
