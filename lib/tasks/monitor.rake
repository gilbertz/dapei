require 'rest_client'
require 'json'

namespace :monitor do
  task :search => :environment do
    urls = []
    urls_fn = "/var/www/shangjieba/monitor.url"
    File.new(urls_fn).each do |line|
      url  = line.strip()
      urls << url
    end 

    params = {}
    #params = {:city_id => 1}
    urls.each do |url|
      p url
      res = RestClient.get url, {:params => params }
      res = JSON.parse(res)
      #p res
      result_count = res['total_found'].to_i
      if result_count == 0
        result_count = res['total_count'].to_i 
      end
      if url.index("editor")
        result_count = res['result']['total_results'].to_i
      end
      p result_count
      if result_count == 0
         info  = "!!!!failed for #{url}"
         `wget -O "sms.wget.log" "http://quanapi.sinaapp.com/fetion.php?u=13818904081&p=831022sjtu&to=13818904081&m=#{info}"`
      end
     
    end

  end

end
