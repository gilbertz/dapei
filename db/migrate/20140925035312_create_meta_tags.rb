class CreateMetaTags < ActiveRecord::Migration
  def change
    create_table :meta_tags do |t|
      t.string :tag
      t.integer :is_show

      t.timestamps
    end
    @init_data = ["搭配", "精选", "单品选集", "t台秀", "潮街拍", "我型我秀"]
    @init_data.each do |data|
      MetaTag.create(tag: "#{data}", is_show: "1")
    end
  end
end
