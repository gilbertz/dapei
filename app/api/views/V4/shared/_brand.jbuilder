json.id @brand.id
json.name @brand.name
json.logo @brand.black_avatar_url
json.intro @brand.brand_intro
json.like_id @brand.is_like(@current_user)
