require 'rest_client'
require 'json'

namespace :matter do
  task :sucai_from_sjb => :environment do
    scs =  Category.where("id > 10 and parent_id = 1140").where(:is_active => true).order("weight desc")
    scs.each do |c|
      (1..50).each do |p|
        page = p.to_s
        cid = c.id.to_s
        url = "http://shangjieba.com/cgi/search.editor_things.json?.in=json&.out=json&request=%7B%22length%22%3A50%2C%22category_id%22%3A%22#{cid}%22%2C%22page%22%3A#{page}%7D"
        p page, cid, url
        res = RestClient.get url
        json = JSON.parse(res)
        if json['result']['items'].length > 0 
          json['result']['items'].each do |i|
            next if Matter.find_by_image_name(i['thing_id'])
            hash = {}
            hash['image_name'] = i['thing_id']
            hash['width'] = i['w']
            hash['height'] = i['h']
            hash['category_id'] = i['category_id']
            m = Matter.new(hash)
            m.save
            p m
          end
        end
      end
    end
  end

end
