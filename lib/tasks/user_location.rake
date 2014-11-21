namespace :seed do
     
  task :user_shop => :environment do
    count = Shop.maximum('id').to_i
    for id in (1..count+1) do
      s = Shop.find_by_id(count-id+1)
      if s
        c = s.user
        ul = UserLocations.find_by_user_id(c.id)
        p c.id, s.jindu, s.weidu, s.city_id
        if ul
          next
          ul = ul.update_attributes(:user_id=>c.id, :jindu=>s.jindu, :weidu=>s.weidu, :city_id => s.city_id)
        else
          ul = UserLocations.create(:user_id=>c.id, :jindu=>s.jindu, :weidu=>s.weidu, :city_id => s.city_id)
        end
      end
    end

  end  


  task :user_comment => :environment do
    puts "test:db"
    Comment.find_each do |c|
      if c.commentable_type == "Shop"
         s = Shop.find(c.commentable_id) 
         if s.jindu and s.weidu and c.user_id
           p c.id, s.jindu, s.weidu, c.user_id
           ul = UserLocations.find_by_user_id(c.user_id)
           if ul
             ul = ul.update_attributes(:user_id=>c.user_id, :jindu=>s.jindu, :weidu=>s.weidu, :city_id => s.city_id)
             next
           else
             ul = UserLocations.create(:user_id=>c.user_id, :jindu=>s.jindu, :weidu=>s.weidu, :city_id => s.city_id)
           end
         end
      end
    end    
  end


end
