object false

node(:result){ 0 }

node(:total_count){ @count }
node(:updated_count){ @updated_count }

cache @cols, expires_in: 10.minutes

child @cols => :dapeis do

    attributes :title, :comments_count, :likes_count, :created_at, :updated_at, :desc, :dapei_img_url
    attributes :url => :dapei_id, :like_id_s => :like_id

    node(:dispose_count){|d| d.incr_and_get_dispose_count }
    node(:img_urls_large){|d| d.get_dpimg_urls }

    node(:share_url){|d| d.share_url }
    node(:share_img){|d| d.share_img }
    node(:share_title){|d| d.share_title }
    node(:share_desc){|d| d.share_desc }
    node(:dapei_items_count){|d| d.get_items_count }

    node :user do |d|
        u = d.get_user
        {
            :user_id => u.url,
            :display_name => u.display_name,
            :name => u.display_name,
            :desc => u.get_desc,
            :is_following => u.can_following?,
            :avatar_img_small => u.display_img_small,
            :avatar_img_medium => u.display_img_medium,
            :dapei_count => u.dapei_count,
            :followers_count => u.followers_count,
            :level => u.get_level,
            :fashion_level => u.show_fashion_level
        }
    end

end