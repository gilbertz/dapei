json.result 0
json.url @default_url
json.meta_tags(@meta_tags) do |meta_tag|
	json.id meta_tag.id
    json.meta_tag meta_tag.tag
    json.meta_image AppConfig[:remote_image_domain]+meta_tag.meta_image.to_s
end
json.themes(@main_tags) do |main_tag|
	json.id main_tag.id.to_s
	json.name main_tag.name
	json.desc main_tag.desc
	json.img_url main_tag.get_img_url
	json.bottom_img_url main_tag.img_url
	json.date main_tag.get_date_detail
	json.user main_tag.get_user_json
	json.share main_tag.share_dict
end