class TagInfo < ActiveRecord::Base
  belongs_to :photo
  belongs_to :tag
  # attr_accessible :title, :body
  # belongs_to :tagging ,:class_name => "ActsAsTaggableOn::Tagging"
  # has_one :tag ,:through => :tagging  ,:source => :tag
  # has_one :taggable ,:through => :tagging
  # belongs_to :target ,:polymorphic => true

  def point_x
    self.coord.split("_")[0]
  end

  def point_y
    self.coord.split("_")[1]
  end

end
