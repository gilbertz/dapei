class MetaTag < ActiveRecord::Base
  mount_uploader :meta_image, MetaImageUploader
  attr_accessible :is_show, :tag,:meta_image
  has_many :dapeis
end
