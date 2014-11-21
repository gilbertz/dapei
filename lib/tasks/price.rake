namespace :dat do

  task :currency => :environment do
    Brand.where("level >=4 ").each do |b|
      b.skus.each do |s|
        if b.currency and b.currency != "" and s.currency != b.currency
          if s.category_id < 100
            p s.title, s.currency, b.name
            s.currency = b.currency
            p s.currency
            s.save
          end
        end
      end
    end
  end

  task :price => :environment do
     count = Sku.maximum('id').to_i
     for id in (1..count+1) do
         sku= Sku.find_by_id(count-id+1)
         if not sku or sku.level.to_i < 3
           next
         end
         if sku and not sku.deleted
           if sku.price and sku.price != ""
             sku.format_price
           end
         end
       
         p sku.price
 
         if sku.price.to_i  > 0 and ( sku.brand.low_price.to_i == 0 )
           sku.brand.low_price = sku.price.to_i
           sku.brand.save
         end
         p sku.brand.low_price
 
         if sku.price.to_i < sku.brand.low_price.to_i and sku.price.to_i > 0
           sku.brand.low_price = sku.price.to_i
           sku.brand.save
         end
         if sku.price.to_i > sku.brand.high_price.to_i
           sku.brand.high_price = sku.price.to_i
           sku.brand.save
         end
     end
     
     count = Brand.maximum('id').to_i
     for id in (1..count+1) do
         brand = Brand.find_by_id(id)
         if brand and brand.level.to_i >= 3
            brand.shops.each do |s|
              if s and s.level.to_i >=2 
                 s.low_price = brand.low_price
                 s.high_price = brand.high_price
                 s.save
              end
            end
         end
     end

  end
    

end
