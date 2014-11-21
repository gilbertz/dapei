# -*- encoding : utf-8 -*-
class Area < ActiveRecord::Base
  scope :dist, lambda { |id|
    where(:city_id=>id, :t=>"district").where("dp_id != ''")
  }
  
  scope :sub, lambda { |dp_id|
    where( :parent_dp_id=>dp_id  )
  }

  scope :bz, lambda { |dp_id|
    where( :parent_dp_id=>dp_id, :t=>"商区")
  }

  scope :db, lambda { |dp_id|
    where( :parent_dp_id=>dp_id, :t=>"地标")
  }

  
  scope :all_cities, lambda {
    where( :t=>'city')
  }

  scope :top_cities, lambda {
    where( :t=>'city').where( "city_id < 350" )
  }
  
  scope :online_cities, lambda {
    where( :t=>'city', :on=>true )
  }

  scope :city, lambda { |city_id|
    where( :city_id=>city_id, :t=>"city" )
  }

  scope :city_pinyin, lambda { |city_pinyin|
    where(:pinyin=>city_pinyin)
  }

  scope :recommended_cities, lambda {
    joins("INNER JOIN recommends ON recommends.recommended_id = areas.id").where( :t=>'city' ).where('recommends.recommended_type' => "Area").order("created_at asc").limit(20)
  }

  scope :city_prefix, lambda { |pinyin|
    pinyin = pinyin.downcase
    cond = "pinyin LIKE '#{pinyin}%'"
    where( :t=>'city', :on=>true ).where("#{cond}")
  }

  def dist_name
    if self.t == "district"
       self.name
    else
       self.parent
    end
  end

  
  def get_pinyin
     rs = ""
     #rs = "#" if Recommend.find_by_recommended_type_and_recommended_id("Area", self.id )        
     rs = "#" if self.city_id and self.city_id <= 8
     if self.pinyin
       rs + self.pinyin
     else
       rs
     end
  end


  acts_as_api
  api_accessible :public, :cache => 300.minutes do |t|
    #t.add :id
    t.add lambda{|area| area.id.to_s}, :as => :id
    #t.add :dp_id
    t.add lambda{|area| area.dp_id.to_s}, :as => :dp_id
    t.add :name
    t.add :get_pinyin, :as => :pinyin
    t.add :parent, :as=>:parent_name
    t.add :t, :as=>:type
    t.add :city_id
    t.add :jindu
    t.add :weidu
    t.add :on
  end


end
