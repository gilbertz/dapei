# -*- encoding : utf-8 -*-
class DapeiItemInfo < ActiveRecord::Base

  belongs_to :dapei_info
  belongs_to :item, :foreign_key => "sjb_item_id"
  belongs_to :sku
  has_one :matter

  attr_accessible :x, :y, :w, :h, :z, :item_type, :thing_id, :sjb_item_id, :sku_id, :bkgd, :transform, :mask_spec, :matter_id


  def get_item(city_id=1, lng=nil, lat=nil)
    if self.sku.blank?
      return nil
    end

    if lng == nil and lat == nil
      cur_city = Area.city(city_id).first
      lng = cur_city.jindu if cur_city
      lat = cur_city.weidu if cur_city
    end

    #if self.sku.items.length > 0
    #   self.sku.items.first
    #else
    #   nil
    #end

    searcher = Searcher.new(city_id, "item", nil,  "near", limit=1, page= "1", nil, nil, lng, lat, nil, self.sku.id)
    
    items = searcher.search()
    if items
       items.first
    else
       self.sku.wrap_item
    end
  end

  def get_brand_name
    if self.get_item.blank? or self.get_item.shop.blank?
      ""
    else
      self.get_item.shop.brand_name
    end
  end

  def get_item_title
    unless self.sku.blank?
      self.sku.title
    else
      ""
    end
  end

  def get_small_img
      AppConfig[:remote_image_domain] +  "/uploads/cgi/img-thing/size/m/tid/#{self.thing_id}.jpg"
  end

  def img_url(png=true)
      if png
          AppConfig[:remote_image_domain] + "/uploads/cgi/img-thing/mask/1/size/orig/tid/#{self.thing_id}.png"
      else
          AppConfig[:remote_image_domain] +"/uploads/cgi/img-thing/size/orig/tid/#{self.thing_id}.jpg"
      end

  end

  def get_matter
      m = Matter.find_by_image_name(self.thing_id) 
      m =  Matter.find_by_sku_id(self.sku_id) if not m and self.sku_id
      m = Matter.new(:image_name => self.thing_id) if not m and ( self.item_type == 'text' or self.item_type == 'image64' or self.item_type == 'image_url' )
      m
  end

  def format_mask_spec_for_mobile
    new_mask_spec = []
    unless mask_spec.blank?
      mask_spec.split(" ").each_slice(2) do |ms|
        new_mask_spec << "{y: #{ms[1]}, x: #{ms[0]}}"
      end
    end
    "[#{new_mask_spec.join(",")}]"
  end

  def get_mask_spec
      matter =self.get_matter
      matter_id = matter.id if matter
      dict = {}
      dict["url"]  =  AppConfig[:remote_image_domain] +"/uploads/cgi/img-thing/mask/1/size/orig/tid/#{self.thing_id}.png" 
      if self.mask_spec
        mask_spec = MaskSpec.find_by_matter_id_and_mask_spec(matter_id, self.mask_spec) 
        if mask_spec
          new_name_png = "#{mask_spec.mask_spec_image_name}.png"             
          #p dict
          dict['template_spec']  == ""
          if mask_spec.mask_spec.split(' ').length == 4
            dict['template_spec'] = mask_spec.mask_spec
          end
          dict["url"] = AppConfig[:remote_image_domain] + "/uploads/cgi/img-thing/mask/1/size/orig/tid/#{new_name_png}" 
          if mask_spec.w and  mask_spec.h
            dict["w"] = mask_spec.w
            dict["h"] = mask_spec.h
          else 
            begin 
              path = "/var/www/shangjieba/public" + "/uploads/cgi/img-thing/mask/1/size/orig/tid/#{new_name_png}"
              if FileTest::exist?(path)
                #p path
                image = MiniMagick::Image.open( path )
              else 
                image = MiniMagick::Image.open( dict["url"])
              end         
              w = image[:width].to_i                                                       
              h = image[:height].to_i 
              dict["w"] = w
              dict["h"] = h
              mask_spec.w = w
              mask_spec.h = h
              mask_spec.save
            rescue => e
              p e.to_s
            end
          end
        end
      end
      return dict
  end

end
