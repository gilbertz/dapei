# -*- encoding : utf-8 -*-
class CreateAppCategoryFeatureImages < ActiveRecord::Migration
  def up
    create_table :app_category_feature_images do |t|
      t.integer :category_id
      t.integer :main_color_id
      t.string :feature_image
    end
  end

  def down
    drop_table :app_category_feature_images
  end
end
