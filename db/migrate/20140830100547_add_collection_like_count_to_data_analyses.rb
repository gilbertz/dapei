class AddCollectionLikeCountToDataAnalyses < ActiveRecord::Migration
  def change
    add_column :data_analyses, :collection_like_count, :integer, default: 0
  end
end
