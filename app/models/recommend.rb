# -*- encoding : utf-8 -*-
class Recommend < ActiveRecord::Base
   validates :recommended_type, :presence => true
   #validates :recommended_id, :presence=>true
   attr_accessible :recommended_type, :recommended_id, :name, :reason, :point

   scope :recommended_streets, lambda { |city_id|
     where(:recommends => {:recommended_type => "Street"}).order("updated_at desc").limit(10)
   }
   scope :recommended_discounts, lambda { |city_id|
     where(:recommends => {:recommended_type => "Discount"}).order("updated_at desc").limit(20)
   }

  acts_as_api
  api_accessible :public, :cache => 180.minutes do |t|
    t.add :recommended_type
    t.add :name
  end
 
  def recommend(type, city_id, category_id=nil)
    
    params = {:city_id => city_id, :index=>type, :from=>"recommend", :limit=>"30" }
    if (type == "item" or type == "sku" or type == "shop" ) and category_id
       params[:cid] = category_id
    end

    res = RestClient.get "http://localhost:8080/info/search.json", {:params => params }
    res = JSON.parse(res)
    #p res  
  
    ids = []
    t = type.capitalize

    type = 'item' if type == "sku"
    if res["#{type}s"] and res["#{type}s"].length > 0
      ids = res["#{type}s"].map { |m| m["#{type}_id"]  }
    end

    ids = ids.sort_by { rand }

    if type == "dapei"
      type = "item"
    end
    
    rn = 5
    if type == "item" or type == "sku"
      rn = 10
    end

    num = 0
    ids.each do |id|
      if ( t != "Sku" and  type == "item" )  or type == "shop"
        id = t.constantize.find_by_url(id).id
      end
      if not Recommend.find_by_recommended_type_and_recommended_id(t, id)
        r = Recommend.create( :recommended_type => t, :recommended_id => id )
        num += 1
        if num >= rn
          break
        end 
        p r
      end
    end 
    return ids 
  end


  def self.cache_recommended_streets_by_city_id(city_id)
    Rails.cache.fetch "recommend/streets/city_id/#{city_id}", :expires_in => 3.minutes do
      Recommend.recommended_streets(city_id).entries
    end
  end
 
end
