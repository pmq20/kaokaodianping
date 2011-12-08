# coding: utf-8
class Topic
  include Mongoid::Document
  include Mongoid::Timestamps
  include Redis::Search
field :answers_count,:type => Integer,:default=>0
  # 软删除标记，1 表示已经删除
  field :deleted, :type => Integer
  scope :normal,where(:deleted=>false)
  scope :recent,desc(:created_at)
# psvr>
  field :website
  field :city,:type=>String,:default=>'北京'
  field :addr
  # 更新标签
  # 参数 tags 可以是数组或者字符串
  # 参数 add  true 增加, false 去掉
  def update_tags(tags, add = true, current_user_id = nil)
    self.tags = [] if self.tags.blank?
    # 分割逗号
    tags = tags.split(/，|,/) if tags.class != [].class
    # 去两边空格
    tags = tags.collect { |t| t.strip if !t.blank? }.compact
    action = nil

    if add
      # 保存为独立的标签
      new_tags = Tag.save_tags(tags, current_user_id)
      self.tags += new_tags
      new_tags.each do |new_tag|
        Tag.collection.update({'_id' => new_tag.id}, {'$inc' => {'topics_count' => 1}})
      end
      action = "ADD_TAG"
    else
      new_tags = Tag.save_tags(tags, current_user_id)
      self.tags -= new_tags
      new_tags.each do |new_tag|
        Tag.collection.update({'_id' => new_tag.id}, {'$inc' => {'topics_count' => -1}})
      end
      action = "DEL_TAG"
    end

    self.current_user_id = current_user_id
    self.tags = self.tags.uniq { |s| s.downcase }
    self.update(:tags => self.tags)
    # insert_topic_action_log(action, topics, current_user_id)
  end
# <psvr

def tags_array=(str)
  self.tags = str.split(',').collect{|str|str.strip}
end

def tags_array
  if self.tags
    self.tags.join(',')
  else
    ''
  end
end

field :tags,type:Array,default:[]
field :schools,type:Array,default:[]
field :courses,type:Array,default:[]

def schools_array=(str)
  self.schools = str.split(',').collect{|str|str.strip}
end

def schools_array
  if self.schools
    self.schools.join(',')
  else
    ''
  end
end

def courses_array=(str)
  self.courses = str.split(',').collect{|str|str.strip}
end

def courses_array
  if self.courses
    self.courses.join(',')
  else
    ''
  end
end
  
  attr_accessor :current_user_id, :cover_changed, :followers_count_changed
  field :will_autofollow,:type=>Boolean
  field :name
  field :summary
  field :cover
  mount_uploader :cover, CoverUploader

  field :asks_count, :type => Integer, :default => 0

  index :name
  index :follower_ids
  index :asks_count

  has_many :logs, :class_name => "Log", :foreign_key => "target_id"

  # Followers
  references_and_referenced_in_many :followers, :stored_as => :array, :inverse_of => :followed_topics, :class_name => "User"

  validates_presence_of :name
  validates_uniqueness_of :name, :case_insensitive => true

  # 以下两个方法是给 redis search index 用
  def followers_count
    self.follower_ids.count
  end

  def followers_count_changed?
    self.followers_count_changed
  end

  def cover_small
    self.cover.small.url
  end

  def cover_small_changed?
    self.cover_changed?
  end
  
  redis_search_index(:title_field => :name,
										 :prefix_index_enable => true,
                     :ext_fields => [:followers_count,:cover_small])
   #Workaround by PSVR
   #https://github.com/huacnlee/redis-search/pull/3
   # after_create :redis_search_index_create
  # 敏感词验证
  before_validation :check_spam_words
  def check_spam_words
    if self.spam?("name")
      return false
    end

    if self.spam?("summary")
      return false
    end
  end

  # Hack 上传图片，用于记录 cover 是否改变过
  def cover=(obj)
    super(obj)
    self.cover_changed = true
  end

  before_update :update_log
  def update_log
    return  if self.current_user_id.blank?
    insert_action_log("EDIT") if self.cover_changed or self.summary_changed?
  end

  def self.save_topics(topics, current_user_id)
    new_topics = []
    topics.each do |item|
      topic = find_by_name(item.strip)
      # find_or_create_by(:name => item.strip)
      if topic.nil?
        topic = create(:name => item.strip)
        begin
          log = TopicLog.new
          log.user_id = current_user_id
          log.title = topic.name
          log.topic = topic
          log.action = "NEW"
          log.diff = ""
          log.save
        rescue Exception => e
          Rails.logger.warn { "Topic save_topics failed! #{e}" }
        end
      end
      new_topics << topic.name
    end
    new_topics
  end

  def self.find_by_name(name)
    find(:first,:conditions => {:name => /^#{name.downcase}$/i})
  end

  def self.search_name(name, options = {})
    limit = options[:limit] || 10
    where(:name => /#{name}/i ).desc(:asks_count).limit(limit)
  end
  include BaseModel
  protected
    def insert_action_log(action)
      begin
        log = TopicLog.new
        log.user_id = self.current_user_id
        log.title = self.name
        log.target_id = self.id
        log.target_attr = (self.cover_changed == true ? "COVER" : (self.summary_changed? ? "SUMMARY" : "")) if action == "EDIT"
        log.action = action
        log.diff = ""
        log.save
      rescue Exception => e
        Rails.logger.info { "#{e}" } 
      end
    end

end
