# -*- encoding : utf-8 -*-

class PushNotification

  def initialize
  end

  def self.get_uds(user_id)
    uds = []
    uds = UserDevice.where(:user_id => user_id).order("updated_at desc").limit(3)
    #uds << ud if ud
    uds
  end


  def self.push_notify(user_id, deploy_status=2)
    @deploy_status = deploy_status
    if true
      uds = get_uds(user_id)

      uds.each do |ud|
        next unless ud
        messages = {title: "title", description: "desc", custom_content: {tag: "Im", type: "Mine"} }
        msg_type = 0
        if ud.device_type == 4
          messages = {aps: { title: '',  badge: 0 },  tag: 'Im', type: 'Mine'} 
          msg_type = 1
        end 
        $baidu_client.push_msg 1, messages, 'msg_key', message_expires: 600, message_type: msg_type, user_id: ud.baidu_uid, device_type: ud.device_type.to_s, deploy_status: @deploy_status
      end
    end
  end


  
  def self.push_status(user_id, msg, deploy_status=2)
    @deploy_status = deploy_status
    if true
      uds = get_uds(user_id)
      uds.each do |ud|
        next unless ud
        messages = {title: msg, description: "desc", custom_content: {tag: "StatusBar", title: msg } }
        msg_type = 0
        if ud.device_type == 4
          messages = {aps: { alert: msg, title: msg,  badge: 0 },  tag: 'StatusBar'}
          msg_type = 1
        end 
        $baidu_client.push_msg 1, messages, 'msg_key', message_expires: 600, message_type: msg_type, user_id: ud.baidu_uid, device_type: ud.device_type.to_s, deploy_status: @deploy_status 
      end
    end 
  end 
         


  def self.push_ssq(user_id, deploy_status=2)
    @deploy_status = deploy_status
    if true
      uds = get_uds(user_id) 
      user = User.find_by_id( user_id )
      
      uds.each do |ud|
        messages = {title: "title", description: "desc", custom_content: {tag:"Im", type:"FashionCircle", img: user.get_ssq_notify_img } }
        msg_type = 0
        if ud.device_type == 4
          messages = {aps: { title: '',  badge: 0 },  tag: 'Im', type: 'FashionCircle', img: user.get_ssq_notify_img}
          msg_type = 1
        end  
        $baidu_client.push_msg 1, messages, 'msg_key', message_expires: 600, message_type: msg_type, user_id: ud.baidu_uid, device_type: ud.device_type.to_s, deploy_status: @deploy_status
      end
    end
  end


  def self.push_dapei_comm_msg(user_id, deploy_status=2)
    @deploy_status = deploy_status
    if true
      uds = get_uds(user_id)
      user = User.find_by_id( user_id )
      t = 'Im'

      uds.each do |ud|
        messages = {title: "title", description: "desc", custom_content: {type: "DapeiCommunity", tag: t } }
        msg_type = 0
        if ud.device_type == 4
          messages = {aps: { title: '',  badge: 0 },  tag: 'DapeiCommunity', type: t}
          msg_type = 1
        end
        p  messages
        $baidu_client.push_msg 1, messages, 'msg_key', message_expires: 600, message_type: msg_type, user_id: ud.baidu_uid, device_type: ud.device_type.to_s, deploy_status: @deploy_status
      end
    end
  end

  
  def self.push_dapei_comm_notify(user_id, id, content='', deploy_status=2)
    @deploy_status = deploy_status
    if true
      uds = get_uds(user_id)
      user = User.find_by_id( user_id )
      dr = AskForDapei.find_by_id(id)
      title = "你的搭配问问已有新回答"
      title = content unless content.blank?

      uds.each do |ud|
        #messages = {aps: {sound:"",  alert:lottery.title,  badge: 1},  tag: 'Hd', detail_url: lottery.link, img: lottery.img_url}
        messages = {aps: {sound:"",  alert: dr.title,  badge: 1},  tag: 'DapeiCommunity', type: "Response", question_title: dr.title, question_id: dr.id}
        if ud.device_type == 3
          messages = {title: title, description: dr.title, custom_content: {tag: "DapeiCommunity", question_title: dr.title, question_id: "#{dr.id}"} }
        end
        p messages
        if ud
          $baidu_client.push_msg 1, messages, 'msg_key', message_type: 1, user_id: ud.baidu_uid, device_type: ud.device_type.to_s, deploy_status: @deploy_status
        end
      end   
    end
  end



  def self.push_dapei_classroom(user_id, deploy_status=2)
    @deploy_status = deploy_status
    if true
      uds = get_uds(user_id)
      user = User.find_by_id( user_id )

      uds.each do |ud|
        #messages = {title: "title", description: "desc", custom_content: {tag: "Im", type: "DapeiClassroom"} }
        messages = {custom_content: {tag: "Im", type: "DapeiClassroom"}, description: "搭配教室红点"}
        msg_type = 0
        if ud.device_type == 4
          messages = {aps: { title: '',  badge: 0 },  tag: 'Im', type: 'DapeiClassroom'}
          msg_type = 1
        end
        $baidu_client.push_msg 1, messages, 'msg_key', message_expires: 600, message_type: msg_type, user_id: ud.baidu_uid, device_type: ud.device_type.to_s, deploy_status: @deploy_status
      end
    end
  end

  
  def self.push_activity(user_id, deploy_status=2)
    @deploy_status = deploy_status
    uds = get_uds(user_id)
    user = User.find_by_id( user_id )
 
    uds.each do |ud|
      lottery = Lottery.last
      messages = {aps: {sound:"",  alert:lottery.title,  badge: 1},  tag: 'Hd', detail_url: lottery.link, img: lottery.img_url}
      if ud.device_type == 3
        messages = {title: lottery.title, description: 'd1', custom_content: {tag: "Hd", detail_url: lottery.link, img: lottery.img_url} }
        #messages = {detail_url: lottery.link, tag: "Hd", img: lottery.img_url, title: lottery.title}
      end
      if ud
        $baidu_client.push_msg 1, messages, 'msg_key', message_type: 1, user_id: ud.baidu_uid, device_type: ud.device_type.to_s, deploy_status: @deploy_status
      end
    end
  end


  def self.push_activity_to_all
      lottery = Lottery.last
      if lottery.on
        messages = {aps: {sound:"",  alert:lottery.title,  badge: 1},  tag: 'Hd', detail_url: lottery.link, img: lottery.img_url}
        device_type = 4
        $baidu_client.push_msg 3, messages, 'msg_key', message_type: 1, device_type: device_type.to_s, deploy_status: @deploy_status
      
        device_type = 3
        messages = {title: lottery.title, description: 'd1', custom_content: {tag: "Hd", detail_url: lottery.link, img: lottery.img_url} }
        $baidu_client.push_msg 3, messages, 'msg_key', message_type: 1,  device_type: device_type.to_s, deploy_status: @deploy_status
      end
  end

  
  def self.push_star_dapei(user_id, dapei_id, deploy_status=2)
    @deploy_status = deploy_status
    uds = get_uds(user_id)
    user = User.find_by_id( user_id )
    uds.each do |ud| 
      dp = Dapei.find_by_url(dapei_id)
      title = "恭喜" + dp.get_user_name + "获得今日之星"
      messages = {aps: {sound:"",  alert:title,  badge: 1},  tag: 'Dapei', id: dapei_id }
      if ud.device_type == 3
        messages = {title: title, description: dp.title, custom_content: {tag:"Dapei", id: dapei_id} }
      end
      if ud
        $baidu_client.push_msg 1, messages, 'msg_key', message_type: 1, user_id: ud.baidu_uid, device_type: ud.device_type.to_s, deploy_status: @deploy_status
      end
    end
  end

  
  def self.push_review_daren(user_id, deploy_status=2)
    @deploy_status = deploy_status
    uds = get_uds(user_id)
    user = User.find_by_id( user_id )
    uds.each do |ud|
      title = "恭喜" + user.name + "通过达人审核"
      messages = {aps: {sound:"",  alert:title,  badge: 1} }
      if ud.device_type == 3
        messages = {title: title, description: "赶快去个人主页查看达人特权", open_type: 2 }
      end
      if ud
        $baidu_client.push_msg 1, messages, 'msg_key', message_type: 1, user_id: ud.baidu_uid, device_type: ud.device_type.to_s, deploy_status: @deploy_status
      end
    end
  end
 
 
  def self.push_review_dapei(user_id, dapei_id, deploy_status=2)
    @deploy_status = deploy_status
    uds = get_uds(user_id)
    user = User.find_by_id( user_id )

    uds.each do |ud|
      dp = Dapei.find_by_url(dapei_id)
      title = "恭喜" + dp.get_user_name + "的搭配被推荐到首页。"
      messages = {aps: {sound:"",  alert:title,  badge: 1},  tag: 'Dapei', id: dapei_id }
      if ud.device_type == 3
        messages = {title: title, description: dp.title, custom_content: {tag:"Dapei", id: dapei_id} }
      end
      if ud
        $baidu_client.push_msg 1, messages, 'msg_key', message_type: 1, user_id: ud.baidu_uid, device_type: ud.device_type.to_s, deploy_status: @deploy_status
      end
    end
  end

  
  def self.push_dapei_msg(user_id, dapei_id, msg, deploy_status=2)
    @deploy_status = deploy_status
    uds = get_uds(user_id)
    user = User.find_by_id( user_id )

    uds.each do |ud|
      dp = Dapei.find_by_url(dapei_id)
      title = msg
      messages = {aps: {sound: "",  alert: title,  badge: 1},  tag: 'Dapei', id: dapei_id }
      if ud.device_type == 3
        messages = {title: title, description: dp.title, custom_content: {tag:"Dapei", id: dapei_id} }
      end
      if ud
        $baidu_client.push_msg 1, messages, 'msg_key', message_type: 1, user_id: ud.baidu_uid, device_type: ud.device_type.to_s, deploy_status: @deploy_status
      end
    end
  end

  def self.push_dapei_pv(user_id, dapei_id, deploy_status=2)
    @deploy_status = deploy_status
    uds = get_uds(user_id)
    user = User.find_by_id( user_id )

    uds.each do |ud|
      dp = Dapei.find_by_url(dapei_id)
      title = "你的搭配已经被浏览了" + dp.get_dispose_count.to_s + "次,点赞了" + dp.likes_count.to_s + "次"
      messages = {aps: {sound: "",  alert: title,  badge: 1},  tag: 'Dapei', id: dapei_id }
      if ud.device_type == 3
        messages = {title: title, description: dp.title, custom_content: {tag:"Dapei", id: dapei_id} }
      end
      if ud
        $baidu_client.push_msg 1, messages, 'msg_key', message_type: 1, user_id: ud.baidu_uid, device_type: ud.device_type.to_s, deploy_status: @deploy_status
      end
    end
  end 
 
  def self.push_msg(user_id, msg, deploy_status=2)
    @deploy_status = deploy_status
    uds = get_uds(user_id)
    user = User.find_by_id( user_id )

    uds.each do |ud|
      title = msg
      messages = {aps: {sound: "",  alert: title,  badge: 1} }
      if ud.device_type == 3
        messages = {title: title, description: title}
      end
      if ud
        $baidu_client.push_msg 1, messages, 'msg_key', message_type: 1, user_id: ud.baidu_uid, device_type: ud.device_type.to_s, deploy_status: @deploy_status
      end
    end
  end  

end
