# -*- encoding : utf-8 -*-
module NotificationsHelper

  def notification_content(note)
    str=""
    if note.notified_object_type=="Follow"
      follower=User.where(:id=>note.object.follower_id).first
      if follower.photos and follower.photos.length>0
        str<<"<span><a class='head_img' href='#{user_path(follower)}'><img src='#{follower.photos[0].url(:thumb_small)}' width='50' /></a></span>"
      else
        str<<"<span><a class='head_img' href='#{user_path(follower)}'><img src='/assets/0.gif' width='50' height='50' /></a></span>"
      end
      str << "<span class='user_control'><p><a class='name' href='#{user_path(follower)}'> #{follower.display_name} </a></p>"
      str << "<p class='time'>#{note.created_at.localtime.strftime("%H:%M")}</p></span>"
      str << "<span class='info'> &nbsp在上街吧关注了你 </span>"
      #str << "<a class='attention_btn' href='#'>关注</a>"
    end

    if note.notified_object_type=="Comment"
      commenter=User.where(:id=>note.object.user_id).first
      if commenter.photos and commenter.photos.length>0
        str<<"<span><a class='head_img' href='#{user_path(commenter)}'><img src='#{commenter.photos[0].url(:thumb_small)}' width='50' /></a></span>"
      else
        str<<"<span><a class='head_img' href='#{user_path(commenter)}'><img src='/assets/0.gif' width='50' height='50' /></a></span>"
      end
      str << "<span class='user_control'><p><a class='name' href='#{user_path(commenter)}'> #{commenter.display_name} </a></p>"
      str << "<p class='time'>#{note.created_at.localtime.strftime("%H:%M")}</p></span>"
      str << "<span class='info'> &nbsp也评论了你评论过的"
      if (note.object.commentable_type=="Shop")
        shop=Shop.find(note.object.commentable_id)
        str<<" 店铺——"
        str << "<a class= 'name' href='#{shop_path(shop)}'>#{shop.name} </a> </p>"
        if shop.photos and shop.photos.length>0
          str<<"<a class='default_img' href='#{shop_path(shop)}'><img src='#{shop.get_display_photo.url(:thumb_medium)}' width='100' /></a>"
        end
      elsif (note.object.commentable_type=="Item")
        item=Item.find(note.object.commentable_id)
        shop=Shop.find(item.shop_id)
        str << "宝贝——"
        str << "<a class= 'name' href='#{shop_item_path(shop, item)}'> #{item.title} </a> </p>"
        if shop.photos and shop.photos.length>0
          str<<"<a class='default_img' href='#{shop_item_path(shop, item)}'><img src='#{item.get_display_photo.url(:thumb_medium)}' width='100' /></a>"
        end
      end
      str<<"</span>"
    end

    if note.notified_object_type=="Like"
      liker=User.where(:id=>note.object.user_id).first
      if liker.photos and liker.photos.length>0
        str<<"<span><a class='head_img' href='#{user_path(liker)}'><img src='#{liker.photos[0].url(:thumb_small)}' width='50' /></a></span>"
      else
        str<<"<span><a class='head_img' href='#{user_path(liker)}'><img src='/assets/0.gif' width='50' height='50' /></a></span>"
      end
      str << "<span class='user_control'><p><a class='name' href='#{user_path(liker)}'> #{liker.display_name} </a></p>"
      str << "<p class='time'>#{note.created_at.localtime.strftime("%H:%M")}</p></span>"
      str << "<span class='info'> &nbsp关注了您的"
      if (note.object.target_type=="Shop")
        shop=Shop.find(note.object.target_id)
        str<<" 店铺——"
        str << "<a class= 'name' href='#{shop_path(shop)}'>#{shop.name} </a> </p>"
        if shop.photos and shop.photos.length>0
          str<<"<a class='default_img' href='#{shop_path(shop)}'><img src='#{shop.get_display_photo.url(:thumb_medium)}' width='100' /></a>"
        end
      end
      str<<"</span>"
    end



    if note.notified_object_type=="Post"
      user=User.where(:id=>note.object.user_id).first
      if user.photos and user.photos.length>0
        str<<"<span><a class='head_img' href='#{user_path(user)}'><img src='#{user.photos[0].url(:thumb_small)}' width='50' /></a></span>"
      else
        str<<"<span><a class='head_img' href='#{user_path(user)}'><img src='/assets/0.gif' width='50' height='50' /></a></span>"
      end
      str << "<span class='user_control'><p><a class='name' href='#{user_path(user)}'> #{user.display_name} </a></p>"
      str << "<p class='time'>#{note.created_at.localtime.strftime("%H:%M")}</p></span>"
      str << "<span class='info'> &nbsp发表了新的"
      post=note.object
      str<<" 日志——"
      str << "<a class= 'name' href='#{user_post_path(user,post)}'>#{post.title} </a> </p>"
        if post.photos and post.photos.length>0
          str<<"<a class='default_img' href='#{user_post_path(user,post)}'><img src='#{post.photos[0].url(:thumb_medium)}' width='100' /></a>"
        end
      str<<"</span>"
    end

    if note.notified_object_type=="Item"
      shop=note.object.shop
      str<<"<span><a class='head_img' href='#{shop_path(shop)}'><img src='#{shop.avatar_url}' width='50' /></a></span>"
      str << "<span class='user_control'><p><a class='name' href='#{shop_path(shop)}'> #{shop.name} </a></p>"
      str << "<p class='time'>#{note.created_at.localtime.strftime("%H:%M")}</p></span>"
      str << "<span class='info'> &nbsp发布了新的"
      item=note.object
      str<<" 宝贝——"
      str << "<a class= 'name' href='#{shop_item_path(shop,item)}'>#{item.title} </a> </p>"
        if item.photos and item.photos.length>0
          str<<"<a class='default_img' href='#{shop_item_path(shop,item)}'><img src='#{item.img_url(:thumb_medium)}' width='100' /></a>"
        end
      str<<"</span>"
    end

    if note.notified_object_type=="Discount"
      shop=note.object.discountable
      str<<"<span><a class='head_img' href='#{shop_path(shop)}'><img src='#{shop.avatar_url}' width='50' /></a></span>"
      str << "<span class='user_control'><p><a class='name' href='#{shop_path(shop)}'> #{shop.name} </a></p>"
      str << "<p class='time'>#{note.created_at.localtime.strftime("%H:%M")}</p></span>"
      str << "<span class='info'> &nbsp发布了新的"
      discount=note.object
      str<<" 优惠——"
      str << "<a class= 'name' href='#{shop_discount_path(shop,discount)}'>#{discount.title} </a> </p>"
      str<<"</span>"
    end

    str.html_safe
  end
  
end
