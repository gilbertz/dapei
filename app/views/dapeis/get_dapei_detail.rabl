object @dapei=>:dapei

attributes :title, :dispose_count, :created_at, :updated_at, :level

node :dapei_id do |d|
  @dapei.url.to_s
end

node :img_url do |d|
  @dapei.img_url
end

node :user_avatar do |d|
  d.user.display_img_medium
end

node :username do |d|
  d.user.display_name
end

node :user_desc do |d|
  d.user.get_desc
end

node :comments_count do |d|
  "#{@comments_count}"
end

node :likes_count do |d|
   "#{@like_users_count}"
end

node :like_id do |dapei|
 "#{dapei.like_id}"
end

node :dapei_items_count do |dapei|
  "#{dapei.get_items_count}"
end

child @comments do
  attributes :user_name, :user_img_small, :comment, :commentable_type, :created_at, :updated_at, :created_time

  node :id do |c|
    "#{c.id}"
  end

  node :commentable_id do |c|
    "#{c.commentable_id}"
  end

  node :user_id do |c|
    "#{c.user_url}"
  end

  node :user do |comment|
    {
    :id => comment.get_user.url.to_s,
    :display_name => comment.get_user.display_name,
    :desc => comment.get_user.desc.to_s,
    :level => comment.get_user.get_level.to_s,
    :is_following => "#{comment.get_user.can_following? ? 1 : 0}",
    :avatar_img_small => comment.get_user.display_img_small,
    :avatar_img_medium => comment.get_user.display_img_medium
    }
  end
  node :to_user do |comment|
    unless comment.get_to_user.blank?
      {
        :id => comment.get_to_user.url.to_s,
        :display_name => comment.get_to_user.display_name,
        :desc => comment.get_to_user.desc,
        :level => comment.get_to_user.get_level.to_s,
        :is_following => "#{comment.get_to_user.can_following? ? 1 : 0}",
        :avatar_img_small => comment.get_to_user.display_img_small,
        :avatar_img_medium => comment.get_to_user.display_img_medium
      }
    end
  end
end

child @like_users, :root => "likes" do
  attributes :display_name => :name, :is_girl => :girl_sex,
  :display_img_small => :avatar_img_small, :display_img_medium => :avatar_img_medium, :get_bg_img => :bg_img, :posts_count_s => :posts_count, :level => :get_level
  attributes :email, :display_name, :birthday, :qq, :age, :city, :v_dapei_count

  node :dapei_count do |u|
   "#{u.dapei_count}"
  end

  node :dapei_likes_count do |u|
    "#{u.dapei_likes_count}"
  end

  node :desc do |u|
    "#{u.desc}"
  end

  node :following_count do |u|
    "#{u.following_count}"
  end

  node :followers_count do |u|
    "#{u.followers_count}"
  end

  node :user_id do |u|
    "#{u.url}"
  end

  node :is_following do |user|
    if user.can_following?
    "1"
    else
    "0"
    end
  end
end
