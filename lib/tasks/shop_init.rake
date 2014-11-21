
namespace :seed do
  task :shop => :environment do

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


end

end
