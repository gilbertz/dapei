class AddStartTimeToDapeiInfo < ActiveRecord::Migration
  def change
    add_column :dapei_infos, :start_time, :datetime
  end
end
