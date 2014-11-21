namespace :user do

 task :check_honour => :environment do
   
   us  = User.order('last_sign_in_at desc').limit(1000)
   us.each do |u|
     p u.name, u.url
     u.check_honour
     p u.get_honour
   end

 end


 task :update_userinfo => :environment do

   User.find_each do |user|

     puts "===============#{Time.now}======================="
     puts "-------------#{user.id}-----------------"


     ui = user.userinfo

     if ui.blank?
       puts "===============create userinfo for user id #{user.id}=================="
       ui = Userinfo.create!(:user_id => user.id)
     end

     follower_count = user.followers_by_type_count('User')
     following_count = user.following_by_type_count('User')

     puts "============#{follower_count}=========#{following_count}================="

     ui.followers_count = follower_count
     ui.following_count = following_count
     ui.save

     puts ui.inspect
     puts "================#{Time.now}===================="
   end

 end

 task :dapei_score => :environment do
     searcher = Searcher.new(nil, "dapei", nil,  "new", 100)
     @dapeis = searcher.search()
     
     idx = 50
     @dapeis.each do |dp|
        idx -= 1
        user = dp.get_user
        user.dapei_score = idx + user.dapei_count.to_i + user.v_dapei_count.to_i * 3 + user.dapei_likes_count.to_i / 10
        user.save
     end
 end


 task :update_dapei_score => :environment do
     @dapeis = Item.where( "category_id >= 1000" ).group(:user_id).order("created_at desc")
     @dapeis.each do |dp|
        user = dp.get_user
        p dp.title, user.url
        user.update_dapei_score if user
     end
 end 


 task :fix_user_url => :environment do
     count = User.maximum('id').to_i
     for id in (1..count+1) do
         p id
         user= User.find_by_id(count-id+1)
         next unless user
         users = User.find_all_by_url(user.url)
         if users.length > 1
           users.each do |u|
             p u
             p "updated for u=" + u.url 
             u.url = u.url + u.id.to_s
             p u.url
             u.save
           end
         end
     end
 end


 task :update_dapei_counter => :environment do
     count = User.maximum('id').to_i
     for id in (1..count+1) do
         p id
         user= User.find_by_id(count-id+1)
         next unless user
         user.update_dapei_counter
     end
 end


 task :update_desc => :environment do
     count = User.maximum('id').to_i
     for id in (1..count+1) do
         p id
         user= User.find_by_id(count-id+1)
         next unless user
         if user.desc == '爱上街，爱搭配'
             user.desc = '爱MAKE，爱生活'
             p id, user
             user.save
         end
     end
 end


 task :update_dapeis_count => :environment do

    User.find_each do |user|

      puts "------------update-------user------------"
      puts user.inspect

      dp_count = Dapei.dapeis_by(user).size

      puts "-----------#{dp_count}--------"

      user.dapeis_count = dp_count
      user.save

      puts user.inspect
      puts "------------updatedddd-------user------------"
    end

  end

end
