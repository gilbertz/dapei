include ActionView::Helpers::SanitizeHelper
namespace :item do
   task :from => :environment do
     count = Sku.maximum('id').to_i
     for id in (1..count+1) do
         sku= Sku.find_by_id(id)
         if sku and sku.brand
           if sku.from != "" and sku.from != "0"
             print "ok:", sku.from, sku.brand.name, "|", sku.from, "|\n"
           else
             print "nok:", sku.from, sku.brand.name, "|", sku.from, "|\n"
             if sku.docid == ""
               sku.from = "shop"
             elsif sku.docid =~ /weibo/
               sku.from = "weibo"
             else
               sku.from = "homepage"
             end 
              print "nok:", sku.from, sku.brand.name, "|", sku.from, "|\n" 
           end
           
           if sku.from != "homepage" and sku.from != "weibo" and sku.from != "shop"
             if sku.brand
               sku.from = "shop"
               print sku.from, "!!!!", sku.brand.name, sku.from, "\n"
             end
           end
           sku.save
         end
     end    
  end

  task :update_data => :environment do
    Item.all.each do |item|
      if item.sku_id
        if Sku.find(item.sku_id)
          item.update_attributes(:brand_id=>Sku.find(item.sku_id).brand_id)
        end
      end
    end
  end

  task :init_index_info => :environment do
    count = 0
    Item.all.each do |item|
      if item.tag_list
        item.update_attributes(:index_info=>item.tag_list.join(","))
      end
      puts item.index_info
      count = count +1
      puts count
    end
  end

  task :update_index_info => :environment do
    count = 0
    Item.all.each do |item|
      if item.index_info.blank?
        count = count+1
        puts count
        puts item.id
        if item.category_id == 1001
          item.find_brands
          puts item.index_info
        end
        if item.index_info.blank?
          item.index_info = ""
          puts "aaaaaaaa"
        end
      end 
    end
  end

  task :remove_html => :environment do
    Item.all.each do |item|
      puts item.id
      puts item.desc
      item.update_attributes(:desc=>strip_links(item.desc))
      puts item.desc
    end
  end
  

  task :init_category_id  => :environment do
    count = 0
    Selfie.all.each do |selfie|     
      selfie.update_attributes(:category_id=>1002)
      puts selfie.id
      count = count +1
      puts count
    end
  end

  task :init_dapei_info_flag  => :environment do
    count = 0
    Dapei.all.each do |dapei|     
      unless dapei.dapei_info
        dapei.update_attributes(:dapei_info_flag=>1)
        puts dapei.id
      end 
      count = count +1
      puts count
    end
  end

  task :init_show_date => :environment do
    count = 0
    Item.find_each(batch_size: 5000) do |item|
      item.show_date = item.created_at
      item.save
      puts count= count +1
      puts item.id
      puts item.show_date
    end
  end

  task :generate_selfie_small_picture => :environment do
    Selfie.all.each do |selfie|
      if selfie.photos.size>0
        selfie.photos.each do |photo|
          selfie_origin_image_path = Photo::Sjb_root.to_s + "/public" + photo.processed_image.url
          selfie_image_path = Photo::Sjb_root.to_s + "/public" + photo.processed_image.thumb_150.url
          unless FileTest::exist? selfie_image_path
            puts photo.processed_image.url
            'convert -resize 150x150 #{selfie_origin_image_path} #{selfie_image_path}'
            puts photo.processed_image.thumb_150.url
          end
        end
      end
    end
  end
end
