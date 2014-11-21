# -*- encoding : utf-8 -*-
# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

#set :environment, "development"

set :output, File.join(File.dirname(__FILE__), '..', 'log', 'scheduled_tasks.log')

# every 1.day, :at => '3:00 am' do
#   rake 'maintenance:clear_carrierwave_temp_uploads'
# end
#
# every 1.day, :at => '2:00 am' do
#   rake 'redis:sync'
# end
#
# every 1.day, :at => '6:00 am' do
#   rake 'tags:add_tags_to_sku'
# end
#
# every 1.day, :at => '4:00 am' do
#   rake 'tags:sub_category'
# end
#
# every '*/2 * * * *' do
#   command "echo 'you can use raw cron syntax too'"
# end

# 每一天给最佳之星发闪币
every 1.day, :at => '12:00 pm' do
  runner "Dapei.get_24hour_star"
end


every '*/4 * * * *' do
  rake 'matter:dispose'
end

every '00 * * * *' do
  rake 'dapei:cron_refresh'
  rake 'dapei:cron_review'
  rake 'dapei:cron_col_review'
  rake 'sku:cron_review'
  rake 'dapei:rand_like_dapei'
  rake 'dapei:sku_head'
  rake 'dapei:fill_matter'
  rake 'dat:update_sku_properties'
  rake 'dat:check_soldout_sku'
  rake 'dat:get_realtime_currency_rate'
  rake 'dat:update_currency_rate'
  rake 'brand:spider_status'
  rake 'dat:clear_sku'
  rake 'dat:update_sku_properties2'
  rake 'dat:update_sku_refer_price'
end

every '05 03 * * *' do
  rake 'dat:item_classify'
  rake 'user:update_dapei_score'
  rake 'matter:get_color'
  rake 'tags:add_tags_to_sku'
  rake 'tags:sub_category'
  rake 'category:item_tagging'
  rake 'sub_category:go'
end


every '50 01 * * *' do
  rake 'dat:clear_sku'
  rake 'dat:price'
  rake 'dat:check_soldout_sku'
  rake 'spider:check_sku'
end


# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
