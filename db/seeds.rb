# -*- encoding : utf-8 -*-

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
puts 'CREATING ROLES'
#Role.create([
#  { :name => 'admin' }, 
#  { :name => 'user' }, 
#  { :name => 'VIP' }
#], :without_protection => true)
#puts 'SETTING UP DEFAULT USER LOGIN'
#user = User.create! :name => 'First User', :email => 'user@example.com', :password => 'please', :password_confirmation => 'please'
#puts 'New user created: ' << user.name
#user2 = User.create! :name => 'Second User', :email => 'user2@example.com', :password => 'please', :password_confirmation => 'please'
#puts 'New user created: ' << user2.name
#user.add_role :admin
#user2.add_role :VIP
roles = Role::ROLES
roles.each do |role|
  Role.find_or_create_by_name(role)
end

file_to_load  = Rails.root + 'db/seed/categories.yml'
categories_list   = YAML::load( File.open( file_to_load ) )
categories_list.each_pair do |key,category|
  s = Category.find_by_abb(category['abb'])
  Category.create(category) unless s
end

admin_file =  Rails.root + 'db/seed/admin.yml'
admin_list = YAML::load( File.open(admin_file) )
admin_list.each_pair do |key, value|
  ad = User.find_by_email(value['email'])
  unless ad
    admin_user=User.create(value)
    admin_user.add_role :admin
  end
end

pat_file = Rails.root + 'db/seed/pat.yml'
pat_list = YAML::load( File.open( pat_file ) ) 
current_city = ""
current_pat = ""
pat_list.each_pair do |key,pat|
   current_city = pat['city'].force_encoding("ASCII-8BIT")
   current_pat = pat['address_pat'].force_encoding("ASCII-8BIT")
end

area_file  = Rails.root + 'db/seed/area.yml'
area_list = YAML::load( File.open( area_file ) )
area_list.each_pair do |key,area|
  #next
  s = Area.find_by_name_and_city(area['name'], area['city'])
#  print area
  Area.create(:name=>area['name'], :city=>area["city"], :city_id=>area['city_code'], :t=>area["type"], :parent=>area["parent"], :parent_dp_id=>area["parent_dp_id"],  :dp_id=>area["dp_id"]) unless s
  s = Area.find_by_name_and_city(area['parent'], area['city']) and area['parent']
  Area.create(:name=>area['parent'], :city=>area["city"], :city_id=>area['city_code'], :t=>"district", :dp_id=>area["parent_dp_id"]) unless s
end

def encode(str)
  if str == ""
    return "sjb"
  end
  new_str =  str.encode('utf-8', 'ASCII-8BIT', :invalid => :replace, 
  :undef => :replace, :replace => '').sub("()", "")
  if new_str == ""
    new_str = "sjb"
  end
  return new_str
end

shop_file  = Rails.root + 'db/seed/shop_data.yml'
shop_list = YAML::load_stream( File.open( shop_file ) )
idx = 0
shop_list.each do |d|
 #next
 d.each_pair do |key, shop|
  #p shop
  shop_url = "sh"+"%06d"%(idx.to_i)
  name = shop_url
  pass = shop_url
  email = "#{name}@shangjieba.com"  

  
  begin
  dp_id = shop['dp_url'].split('/').last
  s = Shop.find_by_dp_id(dp_id)
  print idx, "\n"
  print dp_id, "\n"
  idx += 1
  if not s
    print dp_id, "\n"
    shop_fake_user = User.find_by_email(email)
    shop_fake_user = User.create(:name=>name, :email=>email, :password=>pass, :real=>false ) unless shop_fake_user
    shop_fake_user.add_role :shop_owner
    #pat = "((.+)(区|县))((.+)(路|道|街))"
    
    district = ""
    street = ""
    #if shop['adress']
    #  m = shop['adress'].force_encoding("ASCII-8BIT").match(/#{current_pat}/)
    #  if m
    #    district = m[1]
    #    street = m[4]
    #  end
    #end
    #address = ""
    #if shop['adress']
      #address = shop['adress'].force_encoding("ASCII-8BIT")
    #end
    print "before create"
    s = Shop.create(:url=>shop_url, :name=>shop['name'], :city=>current_city, :phone_number =>shop['tel'], :district=>district, :street=>street, :jindu=>shop['jindu'], \
      :weidu=>shop['weidu'], :address=>"", :user_id=>shop_fake_user.id) 
    s.likes_count = shop['sn'].to_i
    s.comments_count = shop['cn'].to_i
    s.open_hours = shop['open_hours']
    s.tags = shop['tags']
    s.product = shop['product']
    if shop['dp_url']
      s.dp_id = shop['dp_url'].split('/').last.to_i 
    end
    s.rating = shop['rating'].to_i
    #s.type = shop['type']
    s.crawled = 1
    begin
      s.address = shop['adress']
      s.save!
    rescue=>e
      p e.to_s, "for shop=",dp_id
    end
    print "create shop OK", "\n"
    shop['comments'].each do |comment|
      #print comment
      begin
       uname = "sjb#{Digest::MD5.hexdigest(comment['user'])}"
       email = "#{uname}@shangjieba.com"
       cu = User.find_by_email(email)
       name = encode( comment['user'] )
       cu = User.create(:name=>name, :email=>email, :password=>"fakeuser123", :real=>false ) unless cu  
       s.comments.create(:commentable_type=>"Shop", :commentable_id=>s.id, :comment=>comment['text'], :user_id=>cu.id)
      rescue=>e
        p "insert comment error!", e.to_s
        next
      end
    end
     
    pset = []
    for pic in shop['pics']
      begin
        if pic['type']  != "all"
          print '!!1', pic['img']
          photo_params = {:image_url=>pic['img'].sub("249x249", "700x700")}
          photo = shop_fake_user.build_post(:photo, photo_params)
          #photo.text = pic['text']
          p "!! 2"
          photo.target_type = "Item"
          photo.target_type = "Shop"
          photo.target_id = s.id
          photo.save!
          p "!! 3"
          pset << pic['img']
        end
      rescue=>e
          print "!!! insert shop pic failed! shop=#{dp_id}, url=", pic['img'],"\n", e.to_s, "\n"
       end
    end
 
    for pic in shop['pics']
      if pset.include?(pic['img'])
        next
      end

      if pic['type']  == "all"
       begin 
         p "1"
         photo_params = {:image_url=>pic['img'].sub("249x249", "700x700")}
         photo = shop_fake_user.build_post(:photo, photo_params)     
         #photo.text = pic['text']
         photo.target_type = "Item"
         title = "#{encode(pic['text'])}-#{s.id}"
         p "2", title
         item = s.items.create(:title=>title, :shop_id=>s.id, :category_id=>3)
         p "3"
         photo.target_id = item.id
         photo.save!
         p "4"
         #begin
         #  item.title = pic['text']
         #  item.save 
         #rescue=>e
         #  p "update title faild for item", pic['text']
         #end
       rescue=>e
           print "insert item pic failed! shop=#{dp_id}, url=", pic['img'],"\n", e.to_s, "\n"
           next
        end 
      end
    end
  end  
  
  rescue=>e
    print "failed! for dp_id=", dp_id, "\n"
    p e.to_s,"\n"
    next
  end
  end
end


address_fn  = Rails.root + 'db/seed/shop_address.dat'
address_file = File.new( address_fn )
address_file.each do |line|
  items = line.strip().split(/\t| +/)
  dp_id = items[0].split('/').last
  address = items[1]
  #p dp_id, address
  shop = Shop.find_by_dp_id(dp_id)
  if shop
    begin
      shop.address = address
      if items.length >= 3
        tel = items[2]
        p tel
        shop.phone_number = tel
      end
      m = address.force_encoding("ASCII-8BIT").match(/#{current_pat}/)
      p m
      if m
        shop.district = m[1]
        area = Area.find_by_name(m[1])
        if area
          shop.area_id = area.id
        end
        shop.street = m[4]
        p m[1], m[4]
      end
      shop.save!
    rescue=>e
      print e.to_s
    end
  end
end

