# coding: utf-8  
class LandPhoto  
  include Mongoid::Document
  include Mongoid::Timestamps  

  field :image  
  
  belongs_to :user
  
  attr_protected :user_id
  
  # 封面图
  mount_uploader :image, PhotoUploader
  
end
