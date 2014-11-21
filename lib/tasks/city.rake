namespace :seed do
  task :city_pinyin => :environment do
    puts "init city pinyin"
    all_cities = Area.all_cities
    all_cities.each do |city|
      city.pinyin = Pinyin.t(city.name, '')
      p city.pinyin
      city.save
    end
  end

  task :fix_city_id => :environment do
    count = Shop.maximum('id').to_i
    for id in (1..count+1) do
        s = Shop.find_by_id(count-id+1)
        if s and s.city_id > 350
          if s.level  >= 4
            area = Area.find_by_id(s.city_id) 
            if area.t == "city"
              p s.name, s.city_id
              s.city_id = area.city_id
              p s.address, s.city_id
              s.save
            end
          end 
        end
    end
  end
end
