# -*- encoding : utf-8 -*-
#encoding: utf-8
module ManageHelper

  def total_span(objs)
    raw "<span class='label label-success' style='padding-top: 0.3em;'>共
    #{objs.try(:total_entries)} 条</span>"
  end

  def select_tags(id)
    @tags.inject([['无',0]]) do |sum, tag|  
      sum << [tag.name, tag.id] if tag.type_id == id
      sum
    end
  end

  def to_local(time)
    time.utc.in_time_zone("Beijing").strftime("%x %H:%M") unless time.nil?
  end

  def a_active(*name)
    action_name.in?(name) ? 'active' : ''
  end

  def c_active(*name)
    controller_name.in?(name) ? 'active' : ''
  end

  def ac_active(*name)
    controller_name == name[0].to_s && action_name == name[1].to_s ? 'active' : ''
  end
end
