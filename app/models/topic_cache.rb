class TopicCache
  include Mongoid::Document
  field :name
  field :followers_count
  field :hot_rank
  index :name
end