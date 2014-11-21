# -*- encoding : utf-8 -*-
class Tag < ActsAsTaggableOn::Tag
  # has_many :taggings
  attr_accessible :desc, :is_show, :weight, :name, :type_id, :parent_id
  # has_many :taggables , :through => :taggings ,:source => :taggable

  # item对象,标签打的最多的前20条.热门标签
  def self.item_hot_tags_back
    Rails.cache.fetch("item_hot_tags", :expires_in => 10.minutes) do
      # hot_tags = nil
      hot_tags = Item.tag_counts_on(:tags).limit(20)
      if hot_tags.blank?
        hot_tags = ['热','火','霸']  # 初始化标签
      else
        hot_tags = hot_tags.map(&:name)
      end
      hot_tags
    end
  end

    def self.item_hot_tags
        Rails.cache.fetch("item_hot_tags", :expires_in => 300.minutes) do
          hot_tags=[]
          @typesets = Typeset.all
          @typesets.each do |ts|
              next if ts.is_active == 0
              next if ts.typeset_type.cell_types.blank?
              ts.typeset_type.cell_types.each do |ct|
                sc = SetCell.where(:cell_type_id => ct.id, :typeset_id => ts.id).order("id desc").first
                if sc.present? and sc.image.present?
                    hot_tags << sc.tag.name
                end
              end
           end
                                              
          hot_tags
        end
    end


  def to_json
    {
        :id => self.id,
        :name => self.name
    }
  end

end
