class AddStartDateHourToDapeiInfo < ActiveRecord::Migration
  def change
    add_column :dapei_infos, :start_date_hour, :integer
  end
end
