class AddSpiderIdToSpiderPages < ActiveRecord::Migration
  def change
    add_column :spider_pages, :spider_id, :integer
  end
end
