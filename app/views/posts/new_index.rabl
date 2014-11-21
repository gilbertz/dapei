object false
node(:result){1}
node(:total_page){ @posts.total_pages }
node(:current_page){ @posts.current_page }
node(:per_page){ @posts.per_page }
child @posts do
    attributes :id, :title, :desc, :link_url
    node(:thumb_url){|p| p.image_thumb_url }
    node(:created_at){|p| p.created_at_time }
end