namespace :redis do

  task :init => :environment do
    puts "redis:init"
    
    ['shop', 'item', 'discount'].each do |index|
        objs = index.capitalize.constantize.all
        objs.each do |obj|
           key = "#{index}_#{obj.url}"
           if $redis.get(key)
              num = $redis.get(key)
              p key, '->', num, obj.dispose_count
              if not obj.dispose_count or num.to_i <= obj.dispose_count
                 $redis.set(key, obj.dispose_count)
              end
           else
              $redis.set(key, obj.dispose_count)
           end
        end        
    end
  end
 
  task :check_sku => :environment do
    puts "redis:sync"
    redis =  Redis.new(:host => '114.80.100.12', :port => 6379)

    ['sku'].each do |index|
       p index
       redis.keys("#{index}_*").each do |key|
          id = key.split('_')[1]
          obj = nil
          if index == 'discount' or index == "sku"
            obj = index.capitalize.constantize.find_by_id(id)
          else
            obj = index.capitalize.constantize.find_by_url(id)
          end
          if obj != nil
            obj.update_likes_counter
            obj.dispose_count = $redis.get(key)
            print key, '->', obj.dispose_count, "\n"
            obj.save
          end
       end
    end
  end
 

 
  task :sync => :environment do
    puts "redis:sync"
    redis =  Redis.new(:host => '114.80.100.12', :port => 6379)   
 
    ['shop', 'discount', 'sku'].each do |index|
       p index
       redis.keys("#{index}_*").each do |key|
          id = key.split('_')[1]
          obj = nil
          if index == 'discount' or index == "sku"
            obj = index.capitalize.constantize.find_by_id(id)
          else
            obj = index.capitalize.constantize.find_by_url(id)
          end
          if obj != nil
            obj.update_likes_counter
            obj.dispose_count = $redis.get(key)
            print key, '->', obj.dispose_count, "\n"
            obj.save
          end
       end
    end
  end


end
