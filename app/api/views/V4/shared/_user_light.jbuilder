json.user_id user.url
json.display_name user.display_name
json.name user.display_name
json.desc user.get_desc
json.is_following user.is_following
json.avatar_img_small user.display_img_small
json.avatar_img_medium user.display_img_medium
json.dapei_count user.dapei_count.to_s
json.followers_count user.followers_count.to_s
json.level user.get_level.to_s
json.fashion_level user.show_fashion_level.to_s

