# -*- encoding : utf-8 -*-
class AddCampaignImgUrlToBrands < ActiveRecord::Migration
  def change
    add_column :brands, :campaign_img_url, :string
  end
end
