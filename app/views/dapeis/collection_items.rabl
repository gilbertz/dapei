object false

node(:total){ @dapei_item_infos.count }

child @dapei_item_infos => :result do
    node(:image){|dii| dii.sku.img_url(:normal_medium) }
    node(:price){|dii| dii.sku.get_show_price }
    node(:brand_name){|dii| dii.sku.brand_name }
end