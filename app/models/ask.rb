# coding: utf-8
class Ask
  include Mongoid::Document
  include Mongoid::Timestamps
  include Redis::Search
  field :type # either 分校 or 课程 or nil
  # field :search_heuristic
  # field :search_heuristic_pinyin
  def jigou
    self.topics.first
  end
  field :will_autofollow,:type=>Boolean  
  field :title
  field :body
  # 最后回答时间
  field :answered_at, :type => DateTime
  field :answers_count, :type => Integer, :default => 0
  field :comments_count, :type => Integer, :default => 0
  field :topics, :type => Array, :default => []
  field :spams_count, :type => Integer, :default => 0
  field :spam_voter_ids, :type => Array, :default => []
  field :views_count, :type => Integer, :default => 0
  # 最后活动时间，这个时间应该设置为该点评下辖最后一条log的发生时间
  field :last_updated_at, :type => DateTime
  # 重定向点评编号
  field :redirect_ask_id
  scope :has_answer,where(:answers_count.gt=>0)
  index :created_at
  index :topics
  index :user_id
  index :spams_count

  # 提问人
  belongs_to :user, :inverse_of => :asks
  # 对指定人的提问
  belongs_to :to_user, :class_name => "User"

  # 回答
  has_many :answers
  # Log
  has_many :logs, :class_name => "Log", :foreign_key => "target_id"
  # 最后个回答
  belongs_to :last_answer, :class_name => 'Answer'
  # 最后回答者
  belongs_to :last_answer_user, :class_name => 'User'
  # Followers
  references_and_referenced_in_many :followers, :stored_as => :array, :inverse_of => :followed_asks, :class_name => "User"
  # Comments
  has_many :comments, :conditions => {:commentable_type => "Ask"}, :foreign_key => "commentable_id", :class_name => "Comment",dependent: :destroy

  has_many :ask_invites

  attr_protected :user_id
  attr_accessor :current_user_id
  validates_presence_of :title # :user_id
  validates_presence_of :current_user_id, :if => proc { |obj| obj.title_changed? or obj.body_changed? }
  validates_length_of :title,:maximum=>200

  # 正常可显示的点评, 前台调用都带上这个过滤
  scope :normal, where(:spams_count.lt => Setting.ask_spam_max)
  def is_normal?
    spams_count < Setting.ask_spam_max
  end
  scope :last_actived, desc(:answered_at)
  scope :recent, desc("created_at")
  # 除开一些 id，如用到 mute 的点评，传入用户的 muted_ask_ids
  scope :exclude_ids, lambda { |id_array| not_in("_id" => (id_array ||= [])) } 
  scope :only_ids, lambda { |id_array| any_in("_id" => (id_array ||= [])) } 
  # 问我的点评
  field :to_user_ids
  scope :asked_to, lambda { |to_user_id| any_of({:to_user_id => to_user_id},{:to_user_ids=>to_user_id}) }

  redis_search_index(:title_field => :title,:ext_fields => [:topics])
  #Workaround by PSVR
  #https://github.com/huacnlee/redis-search/pull/3
  # after_create :redis_search_index_create
  

  validates_length_of :body,:maximum=>30000

  before_save :fill_default_values
  after_create :create_log, :inc_counter_cache, :send_mails
  after_destroy :dec_counter_cache
  before_update :update_log

  def view!
    self.inc(:views_count, 1)
  end

  def send_mails
    # 向某人提问
    if !self.to_user.blank?
      if self.to_user.mail_ask_me
        UserMailer.deliver_delayed(UserMailer.ask_user(self.id))
      end
    end
  end

  def inc_counter_cache
    self.user.inc(:asks_count, 1) if self.user
  end

  def dec_counter_cache
    if self.user and self.user.asks_count > 0
      self.user.inc(:asks_count, -1)
    end
  end

  def update_log
    insert_action_log("EDIT") if self.title_changed? or self.body_changed?
  end
  
  def create_log
    if self.user
      insert_action_log("NEW")
      if self.to_user_id
        ask_id = self.id
        user_id = self.to_user_id
        invitor_id = self.user_id
        # AskInvite.insert_log(ask_id, user_id, invitor_id)
      end
    end
  end

  # 敏感词验证
  before_validation :check_spam_words
  def check_spam_words
    if self.spam?("title")
      return false
    end

    if self.spam?("body")
      return false
    end

    if self.spam?("topics")
      return false
    end
  end

  def chomp_body
    if self.body == "<br>"
      return ""
    else
      chomped = self.body
      while chomped =~ /<div><br><\/div>$/i
        chomped = chomped.gsub(/<div><br><\/div>$/i, "")
      end
      return chomped
    end
  end
  
  def fill_default_values
    # 默认回复时间为当前时间，已便于排序
    if self.answered_at.blank?
      self.answered_at = Time.now
    end
  end

  # 更新话题
  # 参数 topics 可以是数组或者字符串
  # 参数 add  true 增加, false 去掉
  def update_topics(topics, add = true, current_user_id = nil)
    self.topics = [] if self.topics.blank?
    # 分割逗号
    topics = topics.split(/，|,/) if topics.class != [].class
    # 去两边空格
    topics = topics.collect { |t| t.strip if !t.blank? }.compact
    action = nil

    if add
      # 保存为独立的话题
      new_topics = Topic.save_topics(topics, current_user_id)
      self.topics += new_topics
      action = "ADD_TOPIC"
    else
      self.topics -= topics
      action = "DEL_TOPIC"
    end
    
    self.current_user_id = current_user_id
    self.topics = self.topics.uniq { |s| s.downcase }
    self.update(:topics => self.topics)
    insert_topic_action_log(action, topics, current_user_id)
  end

  # 提交点评为 spam
  def spam(voter_id,size = 1)
    self.spams_count ||= 0
    self.spam_voter_ids ||= []
    # 限制 spam ,一人一次
    return self.spams_count if self.spam_voter_ids.index(voter_id)
    self.spams_count += size
    self.spam_voter_ids << voter_id
    self.current_user_id = "NULL"
    self.save()
    return self.spams_count
  end

  def self.search_title(text,options = {})
    limit = options[:limit] || 10
    Ask.search(text,:limit => limit)
  end

  def self.find_by_title(title)
    first(:conditions => {:title => title})
  end
  
  # 重定向点评
  def redirect_to_ask(to_id)
    # 不能重定向自己
    return -2 if to_id.to_s == self.id.to_s
    @to_ask = Ask.find(to_id)
    # 如果重定向目标的是重定向目前这个点评的，就跳过，防止无限重定向
    return -1 if @to_ask.redirect_ask_id.to_s == self.id.to_s
    self.redirect_ask_id = to_id
    self.save
    1
  end

  # 取消重定向
  def redirect_cancel
    self.redirect_ask_id = nil
    self.save
  end
  
  def tianjia_what
    if self.type
      '点评'
    else
      '回答'
    end
  end
  def typewhat
    if self.type
      self.type
    else
      '问题'
    end
  end
  
  include BaseModel
  protected
  
    def insert_topic_action_log(action, topics, current_user_id)
      begin
        log = AskLog.new
        log.user_id = current_user_id
        log.title = topics.join(',')
        log.ask = self
        log.target_id = self.id
        log.action = action
        log.target_parent_id = self.id
        log.target_parent_title = self.title
        log.diff = ""
        log.save
      rescue Exception => e
        
      end
    end
  
    def insert_action_log(action)
      begin
        log = AskLog.new
        log.user_id = self.current_user_id
        log.title = self.title
        log.ask = self
        log.target_id = self.id
        log.target_attr = (self.title_changed? ? "TITLE" : (self.body_changed? ? "BODY" : "")) if action == "EDIT"
        if(action == "NEW" and !self.to_user_id.blank?)
          action = "NEW_TO_USER"
          log.target_parent_id = self.to_user_id
        end
        log.action = action
        log.diff = ""
        log.save
      rescue Exception => e
        
      end
    end
    

end
