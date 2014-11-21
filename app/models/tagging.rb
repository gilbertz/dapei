# -*- encoding : utf-8 -*-
class Tagging < ActsAsTaggableOn::Tagging
  has_one :tag_info
  belongs_to :tag
end
