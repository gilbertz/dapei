namespace :seed do
   
  task :recreate_350 => :environment do
    puts "recreate 350"
    count = Photo.maximum('id').to_i
    for id in (1..count+1) do
       p = Photo.find_by_id(count-id+1)
       p id
       if p != nil and p.remote_photo_name != nil
           file_path = "/var/www/shangjieba/public/uploads/images/scaled_large_#{p.remote_photo_name}"
           p id, file_path
           if not FileTest::exist? file_path
              begin
                p "recreate scaled_large for id #{p.id}"
                p.unprocessed_image.recreate_versions!
                p p.url(:scaled_large)
              rescue=>e
                p e.to_s
              end
           end
       end
    end 
  end

  task :create_digest => :environment do
    puts "create digest"
    count = Photo.maximum('id').to_i
    for id in (1..count+1) do
       p = Photo.find_by_id(count-id+1)
       p id
       if p != nil and p.target_type == "Sku" and p.remote_photo_name != nil
           file_path = "/var/www/shangjieba/public/uploads/images/#{p.remote_photo_name}"
           if FileTest::exist? file_path
              begin
                p.digest = Digest::MD5.hexdigest(File.read(file_path)) 
                p p.id, p.digest
                p.save
              rescue=>e
                p e.to_s
              end
           end
       end
    end
  end

  task :dup => :environment do
    puts "dup by digest"
    count = Photo.maximum('id').to_i
    for id in (1..count+1) do
       p = Photo.find_by_id(count-id+1)
       if p != nil and p.target_type == "Sku" and p.remote_photo_name != nil 
         if p.digest
           ops = Photo.where("digest=?", p.digest).where("id <?", p.id)
           if ops.length > 0
             op = ops.last
             p "!!! exists", p.id, p.target_id, "vs", op.id, op.target_id
             p p.url(nil), "vs", op.url(nil)
             if op.target_id == p.target_id
              p "innder dup"
              sku = Sku.find_by_id(p.target_id)
              if sku
                p "/brand_admin/brands/#{sku.brand.id}/skus/#{sku.id}"
              end
              p.destroy 
             end
           end
         end
       end
    end
  end


 
  task :recreate_for_brand, [:brand_id] => :environment do |t, args|
    puts "recreate 350"
    brand_id = args[:brand_id]
    brand = Brand.find_by_id(brand_id)
    brand.skus.each do |sku|
       sku.photos.each do |p|
           p sku.id, p.width, p.height
           if sku.from =~ /homepage/
             next
           end
           if  p != nil and p.remote_photo_name != nil
             file_path = "/var/www/shangjieba/public/uploads/images/wide_half_#{p.remote_photo_name}"
             p sku.title, sku.id, file_path
             if not FileTest::exist? file_path
               begin
                 p "recreate scaled_large for id #{p.id}"
                 p.unprocessed_image.recreate_versions!
                 p.processed_image.recreate_versions!
                 p p.url(:normal_medium)
               rescue=>e
                 p e.to_s
               end
             end
           end
       end
    end
  end 


  task :recreate_xc_for_brand, [:brand_id] => :environment do |t, args|
    puts "recreate xuanchuan tu"
    brand_id = args[:brand_id]
    brand = Brand.find_by_id(brand_id)
    brand.skus.where( "skus.category_id > 100" ).each do |sku|
       sku.photos.each do |p|
           p sku.id, p.width, p.height
           if  p != nil and p.remote_photo_name != nil
             file_path = "/var/www/shangjieba/public/uploads/images/wide_half_#{p.remote_photo_name}"
             p sku.title, sku.id, file_path
             if not FileTest::exist? file_path
               begin
                 p "recreate wide half for id #{p.id}"
                 p.unprocessed_image.recreate_versions!
                 p p.url(:normal_medium)
               rescue=>e
                 p e.to_s
               end
             end
           end
       end
    end
  end




  task :rescue_normal => :environment do
    puts "rescue normal"
    count = Photo.maximum('id').to_i
    for id in (1..count+1) do
       p = Photo.find_by_id(count-id+1)
       p id
       if p != nil and p.remote_photo_name != nil
           file_path = "/var/www/shangjieba/public/uploads/images/normal_small_#{p.remote_photo_name}"
           p id, file_path
           if not FileTest::exist? file_path
             p.n2s = true
             p.save
           elsif p.n2s
             p.n2s = nil
             p.save
           end
       end
    end
  end

  task :sync_normal => :environment do
    puts "rescue normal"
    count = Photo.maximum('id').to_i
    for id in (1..count+1) do
       p = Photo.find_by_id(count-id+1)
       p id
       if p != nil and p.remote_photo_name != nil
           file_path = "/var/www/shangjieba/public/uploads/images/normal_small_#{p.remote_photo_name}"
           if not FileTest::exist? file_path
             sync_photo(p.remote_photo_name)
           end
       end
    end
  end


  task :recreate_300x400_150X200 => :environment do
    puts "recreate _300x400_150X200"
    count = Photo.maximum('id').to_i
    for id in (1..count+1) do
       p = Photo.find_by_id(count-id+1)
       p id
       if p != nil and p.remote_photo_name != nil
           file_path = "/var/www/shangjieba/public/uploads/images/normal_small_#{p.remote_photo_name}"
           file_path1 = "/var/www/shangjieba/public/uploads/images/scaled_medium_#{p.remote_photo_name}"
           p id, file_path
           if not FileTest::exist? file_path
              begin
                p "recreate normalversion for id #{p.id}"
                p.unprocessed_image.recreate_versions!
                p p.url(:normal_small), p.url(:normal_medium)
              rescue=>e
                p e.to_s
              end
           end
           #p id, file_path1
           #if not FileTest::exist? file_path1
           #   begin
           #     p "recreate scaled version for id #{p.id}"
           #     p.unprocessed_image.recreate_versions!
           #     p p.url(:scaled_medium)
           #   rescue=>e
           #     p e.to_s
           #   end
           #end 
       end
    end
  end

  task :recreate_wide => :environment do
    puts "recreate _wide"
    count = Photo.maximum('id').to_i
    for id in (1..count+1) do
       p = Photo.find_by_id(count-id+1)
       p id
       if p != nil and p.remote_photo_name != nil
           file_path = "/var/www/shangjieba/public/uploads/images/wide_half_#{p.remote_photo_name}"
           p id, file_path
           if not FileTest::exist? file_path
              begin
                p "recreate wide half version for id #{p.id}"
                p.processed_image.recreate_versions!
                p p.url(:wide_half)
              rescue=>e
                p e.to_s
              end
           end
           #p id, file_path1
           #if not FileTest::exist? file_path1
           #   begin
           #     p "recreate scaled version for id #{p.id}"
           #     p.unprocessed_image.recreate_versions!
           #     p p.url(:scaled_medium)
           #   rescue=>e
           #     p e.to_s
           #   end
           #end 
       end
    end
  end
 

  task :enhance_photo => :environment do
    puts "enhance photo"
    count = Photo.maximum('id').to_i
    for id in (1..count+1) do
       p = Photo.find_by_id(id)
       p id
       if id < 57686
         next
       end
       if p != nil and p.remote_photo_name != nil
           file_path = "/var/www/shangjieba/public/uploads/images/#{p.remote_photo_name}"
           print file_path
           if  FileTest::exist? file_path
              begin
                p.unprocessed_image.recreate_versions!
                p.processed_image.recreate_versions!
              rescue=>e
                p e.to_s
              end
           end
       end
    end
  end


  
  task :not_enhance_photo => :environment do
    puts "not enhance photo"
    count = Photo.maximum('id').to_i
    brand_ids = [485,77,79,496,117,273,493]
    brand_ids.each do |bid| 
       brand = Brand.find_by_id(bid)
       if brand
         skus = brand.skus
         skus.each do |sku|
           p sku
           if sku.docid and sku.docid != ""
            sku.photos.each do |p|
             if p != nil and p.remote_photo_name != nil
               file_path = "/var/www/shangjieba/public/uploads/images/#{p.remote_photo_name}"
               print file_path, "\n"
               if  FileTest::exist? file_path
                 begin
                   p.unprocessed_image.recreate_versions!
                   p.processed_image.recreate_versions!
                 rescue=>e
                   p e.to_s
                 end
               end
             end
            end
           end
         end
       end
    end
  end



  task :fill_img_dimension => :environment do
    puts "fill:img_dimension"
    count = Photo.maximum('id').to_i
    print count
    for id in (1..count) do
       p = Photo.find_by_id(id)
       if p != nil and p.remote_photo_name != nil and p.target_type = "Item"
           medium_path = "/var/www/shangjieba/public/uploads/images/scaled_medium_#{p.remote_photo_name}"
           file_path = "/var/www/shangjieba/public/uploads/images/#{p.remote_photo_name}"
           p p.id
           #print medium_path 
           if id < 46500 or not FileTest::exist? medium_path
           #if not FileTest::exist? medium_path
              if  FileTest::exist? file_path 
                 print "!!! medium path #{medium_path} not present for photo id=", p.id, "\n"
                 print "!!!", p.width, "*", p.height, "\n"
                 p.unprocessed_image.recreate_versions!
                 #break
              end
           end
           #file_path = "/var/www/shangjieba/public/uploads/images/" + p.remote_photo_name
           #if p.width == nil or p.height == nil
           #   p.width, p.height = `identify -format "%wx%h " #{file_path}`.split(/x/)          
           #   p.save!
           #   print p.width, "x", p.height, "\n"
           #end
       end
    end
  end


  task :img => :environment do
    puts "test:db"
    
    img_fn  = Rails.root + 'db/seed/img_list'
    img_file = File.new( img_fn )
    imgs = []
    img_file.each do |line|
      #p line.strip()
      imgs << line.strip
    end
    #users = User.all
    n = 0
    size = imgs.length

    count = User.maximum('id').to_i
    p count
    #users.each do |u|
    for id in (1..count) do
      u = User.find_by_id(id) 
      if u == nil
         next
      end
      #p u.profile_img_url
      if u.profile_img_url != nil
         next   
      end
      img_fn = Digest::MD5.hexdigest( imgs[n%size] )
      `wget  -t 10  -nc -c -x -O /var/www/shangjieba/public/uploads/thumb/#{img_fn} #{imgs[n%size]}`
      u.profile_img_url = "/uploads/thumb/#{img_fn}"
      u.save!
      p "/uploads/thumb/#{img_fn}" 
      n += 1       
    end
  end
end
