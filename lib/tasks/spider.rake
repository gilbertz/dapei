namespace :spider do
  task :check_sku  => :environment do
    spiders = Spider.where(:stop => true)
    spiders.each do |s|
      s.check_sku
    end 
  end
  
  task :check_brand_sku, [:brand_id] => :environment do |t, args|
    brand_id = args[:brand_id]
    spiders = Spider.where(:brand_id => brand_id)
    spiders.each do |s|
      p s
      s.check_sku if s.stop
    end
  end
end
