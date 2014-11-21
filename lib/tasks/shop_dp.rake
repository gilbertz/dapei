# encoding: utf-8

def traverse_dir(file_path)
  if File.directory? file_path
    Dir.foreach(file_path) do |file|
      if file!="." and file!=".."
        print "dir=", file, "\n"
        traverse_dir(file_path+"/"+file){|x| yield x}
      end
    end
  else
    yield  file_path
  end
end


namespace :seed do
  task :activate_city  => :environment do
    (1..350).each do |city_id|
      shops = Shop.where(:city_id => city_id).where("level >= ?", 3)
      #p shops.length
      city = Area.city(city_id).first
      next if not city
      if shops.length > 1
        city.on = true
        p city
      else
        city.on = false  
      end
      city.save
    end
  end


  task :mall_dp, [:city_id] => :environment do |t, args|
    city_id = args[:city_id]
    s = "/var/www/shangjieba_dat/dianping/mall"
    traverse_dir(s){|f|
      if f !~ /yml/
        next
      end

      print "processing #{f} ...\n"
      docs = YAML::load( File.open( f ) )
      if docs
        docs.each do |d|
          if d[:city_id] != city_id
           next
          end
          m = Mall.find_by_name_and_city_id(d[:name], d[:city_id])
          d[:name] = d[:name].gsub(/[\(\)]+/, "").gsub(/店$/, "")
          d[:pattern] = d[:name] + "#" + d[:address]
          m = Mall.new(d) unless m     
          m.save
          p m 
        end
      end
    }
  end

  task :parse_lnglat => :environment do
    count = Shop.maximum('id').to_i
    file =  File.open("/var/www/shangjieba_dat/lnglat_not_parsed.list","w")
    for id in (1..count+1) do
      begin
        s = Shop.find_by_id(count-id+1) 
        if s and  not s.jindu and not s.weidu
          city_name = Area.city( s.city_id ).first.name
          p s.address, city_name, s.name
          res = RestClient.get "http://api.map.baidu.com/geocoder", {:params => {:address => s.address, :output=>"json", :city=>city_name} }
          res = JSON.parse(res)
          p res
          if res["status"] == "OK" and res["result"] and res["result"]["location"]
            p s.jindu, s.weidu
            s.jindu = res["result"]["location"]["lng"]
            s.weidu = res["result"]["location"]["lat"]
            p s.jindu, s.weidu
            s.save
          else
            p "#{s.dp_id}\t#{city_name}\t#{s.address}\t#{s.name}"
            file.puts "#{s.dp_id}\t#{city_name}\t#{s.address}\t#{s.name}\n"
          end
        end
      rescue=>e
        p e.to_s
        file.puts "#{s.dp_id}\t#{city_name}\t#{s.address}\t#{s.name}\n"
      end
    end
  end

  task :dp, [:city_id] => :environment do |t, args|
    city_id = args[:city_id]
    s = "/var/www/shangjieba_dat/dianping/dat"
    traverse_dir(s){|f|
      if f !~ /yml/
        next
      end

      print "processing #{f} ...\n"
      docs = YAML::load( File.open( f ) )
      if docs
        docs.each do |d|
          p city_id + "vs" + d[:city_id]
          if city_id != d[:city_id]
            next
          end
          s = Shop.find_by_dp_id( d[:dp_id] )
          if s
            print s
          else
            s = Shop.create(d) 
          end
          if not s.user 
            url = d[:name].to_url.to_url
            url = url +"-" +Shop.maximum('id').to_s if s
            email = "#{url}@shangjieba.com"
            auto_user = User.find_by_email(email)
            url = url +"-" +User.maximum('id').to_s if auto_user
            email = "#{url}@shangjieba.com"
            auto_user = User.new(:name=>url, :email=>email, :password=>"shangjieba", :real=>false )
            auto_user.save!

            auto_user.add_role :shop_owner
            s.user_id  = auto_user.id
            s.save
          end
	  #break
        end
      end
    }
  end
end
