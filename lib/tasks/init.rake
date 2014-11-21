namespace :init do
  task :pv => :environment do
    puts "init:pv"
    ['shop', 'item', 'discount'].each do |index|
          objs = index.capitalize.constantize.all
          objs.each do |obj|
            if index == 'discount'
               obj.dispose_count = obj.discountable.dispose_count + rand(50)
            else
               if obj.comments_count and obj.likes_count
                   obj.dispose_count = 20*obj.comments_count + 10*obj.likes_count + rand(15)
               else
                   obj.dispose_count = rand(100)
               end
            end
            print index, obj.id, '->', obj.dispose_count, "\n"
            if index == "item"
               obj.likes_count = rand(20)
               #obj.comments_count = rand(10)
            end
            obj.save
          end
    end
  end
end
