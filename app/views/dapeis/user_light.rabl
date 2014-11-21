node :get_user do |comment|
    {
    :id => comment.get_user.id,
    :display_name => comment.get_user.display_name,
    :desc => comment.get_user.desc,
    :level => comment.get_user.get_level.to_s
    :is_following => comment.get_user.can_following?
    :avatar_img_small => comment.get_user.display_img_small
    :avatar_img_medium => comment.get_user.display_img_medium
    }
end