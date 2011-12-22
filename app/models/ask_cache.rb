class AskCache
  include Mongoid::Document
  field :ask_id
  index :ask_id,unique:true
  field :hot_rank
end