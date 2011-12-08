# coding: utf-8  
class LandSection
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :sort, :type => Integer, :default => 0
  has_many :nodes, :class_name => 'LandNode',:foreign_key=>'section_id', :dependent => :destroy
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  
  default_scope desc(:sort)
end
