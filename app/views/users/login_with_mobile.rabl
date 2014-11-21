object false
if @state == "success"

   node(:error){0}

    child @user do
        attributes :mobile, :name, :age, :birthday, :city, :is_girl

        node(:user_id){|u| u.url }
        node(:level){|u| u.get_level }
        node(:bg_img){|u| u.get_bg_img }
        node(:avatar_img_medium){|u| u.display_img_medium }
        node(:display_name){|u| u.display_name }
        node(:token){|u| u.authentication_token }

    end

end
