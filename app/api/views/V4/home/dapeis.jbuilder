if @items
  json.total_count @items.total_entries
else
  json.total_count 0
end
json.result 0
if @brand
  json.type "brand"
  json.brand do
    json.partial! 'V4/shared/brand', :brand => @brand
  end
else
  json.type "" 
end

json.dapeis(@items) do |item|
  json.id item.id
  json.dapei_id item.url
  json.title item.show_title
  json.comments_count item.comments_count.to_s
  json.likes_count item.likes_count.to_s
  json.dispose_count item.dispose_count.to_s
  json.img_urls_large item.get_dpimg_urls
  json.dapei_img_url item.get_dapei_img_url
  json.desc item.get_editor_desc.to_s
  json.like_id item.like_id_s
  json.created_at item.updated_at
  json.updated_at item.updated_at
  json.share_url item.share_url
  json.share_img item.share_img
  json.share_title item.share_title
  json.share_desc item.share_desc
  json.dapei_items_count item.get_items_count
  json.type item.class.name.downcase
  if item.meta_tag
    json.meta_tag_id item.meta_tag.id
    json.meta_tag_name item.meta_tag.tag
    json.meta_tag_image AppConfig[:remote_image_domain]+item.meta_tag.meta_image.to_s
  end
  json.user do
    json.partial! 'V4/shared/user_light', :user => item.get_user
  end
  json.tags item.get_api_tags
end
