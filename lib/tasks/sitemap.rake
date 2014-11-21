class TaskActionView < ActionView::Base
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::TagHelper

  def default_url_options
     {host: 'www.shangjieba.com'}
  end
end

def action_view
  controller = ActionController::Base.new
  controller.request = ActionDispatch::TestRequest.new
  TaskActionView.new(Rails.root.join('app', 'views'), {}, controller)
end



namespace :seo do
  task :sitemap => :environment do
    sitemap_xml_fn  = Rails.root + 'public/sitemap.xml'
    sitemap_xml_file =  File.new( sitemap_xml_fn, "w" )
    sitemap_xml_file.puts action_view.render(:template =>"sitemap/link")

    sitemap_fn  = Rails.root + 'public/sitemap.txt'
    sitemap_fn1  = Rails.root + 'public/sitemap1.txt'
    sitemap_fn2 = Rails.root + 'public/sitemap2.txt'

   

    sitemap_file = File.new( sitemap_fn, "w" )
    sitemap_file1 =  File.new( sitemap_fn1, "w" )
    sitemap_file2 =  File.new( sitemap_fn2, "w" )
    domain = "http://www.shangjieba.com"
    shops = Shop.all
    shops.each do |s|
      sitemap_file.puts domain + "/#{s.url}"
    end
    #Item.all.each do |i|
    #  puts domain + shop_item_path(i.shop, i)
    #end
    #Discount.all.each do |d|
    #  puts domain + shop_discount_path(d.shop, d)
    #end
    users = User.all
    users.each do |u|
      sitemap_file1.puts domain + "/users/#{u.url}"
    end
    items = Item.all
    items.each do |item|
      sitemap_file2.puts domain + "/#{item.shop.url}/#{item.url}.htm"
    end


  end

end

