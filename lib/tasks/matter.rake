namespace :matter do
  
  task :dispose => :environment do
    Matter.where("is_cut is null or is_cut = 0").find_each do |m|
      m.dump
    end 
  end


  task :jpg2png => :environment do
    p "jpg2png"
    matters = Matter.where("rule_category_id=2471")
    jpg2png = "/var/ImageDispose/jpg2png/jpg2png"
    matters.each do |m|
      p m
      dir = "/var/www/shangjieba/public"
      jpg = "#{dir}/uploads/cgi/img-thing/size/orig/tid/#{m.image_name}.jpg"
      png = "#{dir}/uploads/cgi/img-thing/mask/1/size/orig/tid/#{m.image_name}.png"
      p "#{jpg2png} #{jpg} #{png}"
      `#{jpg2png} #{jpg} #{png}`
    end

  end

  
  task :repair => :environment do
    puts "matter repair"
    count = Matter.maximum('id').to_i

    for id in (1..count+1) do
       begin 
         m = Matter.find_by_id(count-id+1)
         if m and m.image_name
           path = "/var/www/shangjieba/public/uploads/cgi/img-thing/mask/1/size/orig/tid/#{m.image_name}.png"
           sz = File.size(path)
           if not FileTest::exist? path or sz < 500
             m.dump
           end
         end
       rescue => e
         p e.to_s 
       end
    end
  end

  task :repair_category => :environment do
    puts "matter repair"
    count = Matter.maximum('id').to_i

    for id in (1..count+1) do
       begin
         m = Matter.find_by_id(count-id+1)
         if m and m.sku
           m.sku.check_sub_category
         end
       rescue => e
         p e.to_s
       end
    end
  end
 
 
  task :fix_img_size => :environment do
    puts "matter repair"
    count = Matter.maximum('id').to_i

    for id in (1..count+1) do
       begin
         m = Matter.find_by_id(count-id+1)
         p id if id%100 == 0
         next unless m
         next if m.sku_id
         #break if id > 20000
         next if m.width.to_i >= 600
         if m and m.image_name
           m.fix_img_size
         end
       rescue => e
         p e.to_s
       end
    end
  end


  task :dup => :environment do
    puts "matter dup"
    count = Matter.maximum('id').to_i
 
    for id in (1..count+1) do
       m = Matter.find_by_id(count-id+1)
       if m and m.image_name
         #p m.image_name
         path = "/var/www/shangjieba/public/uploads//cgi/img-thing/size/s/tid/#{m.image_name}.jpg" 
         sz = File.size(path) 
         if sz < 500
           p sz, "http://img.shangjieba.com/uploads//cgi/img-thing/size/s/tid/" + m.image_name + ".jpg"
           m.destroy
         end
       end
    end
  end
  
  task :fix_color => :environment do
    color1 = Color.find_by_color_16('778899').id
    color2 = Color.find_by_color_16('eedfcc').id
    color3 = Color.find_by_color_16('a2b5cd').id
    
    count = Matter.maximum('id').to_i    
    for id in (1..count+1) do
      begin
        m = Matter.find_by_id(count-id+1)
        if m and m.color_one_id == color1 and m.color_two_id == color2 and m.color_three_id == color3
          m.make_color
          p "#{id}  #{m.color_one_id} #{m.color_two_id} #{m.color_three_id}"
        end
      rescue => e
        p e.to_s
      end
    end
  end 


  task :get_color => :environment do
      url = "http://wx.shangjieba.com:7777/service/dapei/get_color"
      count = Matter.maximum('id').to_i    
      for id in (1..count+1) do
        begin
          m = Matter.find_by_id(count-id+1)
          p "!!!", m.id, m.color_one_id, m.color_two_id, m.color_three_id if m
          next unless m
          next if  m.color_one_id or m.color_two_id or m.color_three_id
          p id,m
          p m.matter_img_url
          params = {:image_url => m.matter_img_url }
          #url1 = "http://wx.shangjieba.com:7777/service/dapei/get_color?image_url=http://qingchao1.qiniudn.com/uploads/cgi/img-thing/mask/1/size/orig/tid/1390546259470.png"
          res = RestClient.get url, {:params => params }
          #res = RestClient.get url1
          res = JSON.parse(res)
          colors = res["colors"]
          color_arr = colors.split(" ")
          if color_arr.size == 3
            color_arr.each_with_index do |c, index|
              co = Color.find_by_color_16(c)
              unless co.blank?
                if index == 0
                  m.color_one_id = co.id
                elsif index == 1
                  m.color_two_id = co.id
                elsif index == 2
                  m.color_three_id = co.id
                end
              end
            end
            m.save
          end
          p m
        rescue => e
          p e.to_s
        end

      end
  end

end
