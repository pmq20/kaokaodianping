# coding: utf-8

class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Voter
  include Redis::Search

  scope :normal,where(:deleted.ne=>1,:xiaohao.ne=>true)
  index :created_at
  field :location
  field :verified, :type => Boolean, :default => false
  field :xiaohao, :type => Boolean, :default => false
  field :state, :type => Integer, :default => 1


  def integrity_op
    self.asks_count = self.asks.count
    self.answers_count = self.answers.count
    self.answered_ask_ids = self.answers.collect(&:id)
  end

  field :replies_count, :type => Integer, :default => 0  
  has_and_belongs_to_many :following_nodes, :class_name => 'Node', :inverse_of => :followers
  has_many :land_topics, :dependent => :destroy  
  has_many :land_notes
  has_many :land_replies


  
  def avatar_url(mtd)
    avaurl = self.avatar.send(mtd).url
    if avaurl.blank?
      avaurl = ''
    elsif "avatar/small.jpg"==avaurl
      avaurl="avatar/small_trans.jpg"
    end
    unless avaurl.starts_with?('/uploads/')
      avaurl = '/images/'+avaurl
    end
    avaurl
  end
  def login
    email
  end
  def login=
    raise 'no login='
  end
  # default_scope where(:deleted => nil)
  def slug
    ret = read_attribute(:slug)
    if ret
      ret.split('.').join('_')
    else
      self.name
    end
  end

  def slug=(arg)
    write_attribute(:slug,arg.split('.').join('_'))
  end
  def self.human_attribute_name(attr, options = {})
    case attr.to_sym
    when :tagline
      '一句话描述'
    when :name
      '昵称'
    when :slug
      '个性域名'
    else
      attr.to_s
    end
  end


  field :current_mails
  
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  field :is_expert, :type=>Boolean
  field :is_expert_why
  field :name
  field :slug
  field :tagline
  field :tagline_changed_at
  before_save Proc.new{
    if self.tagline_changed?
      self.tagline_changed_at = Time.now
    end
  }
  field :will_autofollow,:type=>Boolean
  field :bio
  field :avatar
  field :website
  # 是否是女人
  field :girl, :type => Boolean, :default => false
  # 软删除标记，1 表示已经删除
  field :deleted, :type => Integer
  # 是否是可信用户，可信用户有更多修改权限
  field :credible, :type => Boolean, :default => false

  # 不感兴趣的点评
  field :muted_ask_ids, :type => Array, :default => []
  # 关注的点评
  field :followed_ask_ids, :type => Array, :default => []
  # 回答过的点评
  field :answered_ask_ids, :type => Array, :default => []
  # Email 提醒的状态
  field :mail_be_followed, :type => Boolean, :default => true
  field :mail_new_answer, :type => Boolean, :default => true
  field :mail_invite_to_ask, :type => Boolean, :default => true
  field :mail_ask_me, :type => Boolean, :default => true
  field :thanked_answer_ids, :type => Array, :default => []

  # 邀请字段
  field :invitation_token
  field :invitation_sent_at, :type => DateTime


  field :asks_count, :type => Integer, :default => 0
  has_many :asks

  field :answers_count, :type => Integer, :default => 0
  has_many :answers
  has_many :notifications
  has_many :inboxes
field :banished

  index :slug, :uniq => true
  index :email, :uniq => true
  index :follower_ids
  index :following_ids
  def following_names
    self.following_ids.collect{|id|User.find(id).name}
  end
  index :followed_ask_ids
  index :followed_topic_ids

  references_and_referenced_in_many :followed_asks, :stored_as => :array, :inverse_of => :followers, :class_name => "Ask"
  references_and_referenced_in_many :followed_topics, :stored_as => :array, :inverse_of => :followers, :class_name => "Topic"
  
  references_and_referenced_in_many :following, :class_name => 'User', :inverse_of => :followers, :index => true, :stored_as => :array
  references_and_referenced_in_many :followers, :class_name => 'User', :inverse_of => :following, :index => true, :stored_as => :array

  embeds_many :authorizations
  has_many :logs, :class_name => "Log", :foreign_key => "target_id",dependent: :destroy

  attr_accessor  :password_confirmation
  # attr_accessor :tags_array
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
  
  field :tags
  attr_accessible :banished,:email, :password,:name, :slug, :tagline, :bio, :avatar, :website, :girl, 
                  :mail_new_answer, :mail_be_followed, :mail_invite_to_ask, :mail_ask_me,
                  :credible, :is_expert, :is_expert_why, :tags, :will_autofollow

  validates_presence_of :name, :slug
  validates_uniqueness_of :slug,:message=>'与已有个性域名重复，请尝试其他域名'
  validates_format_of :slug, :with => /[a-z0-9\-\_]{3,20}/i, :unless=>'self.new_record?'
  field :name_last_changed_at
  validate :name_change_not_too_often
  # 用户修改昵称，一个月只能修改一次
  def name_change_not_too_often
    if self.name_changed?
      if self.name_last_changed_at and self.name_last_changed_at > 1.months.ago
        errors.add_to_base "对不起，昵称一个月只能修改一次"
        return false
      else
        self.name_last_changed_at = Time.now
        return true
      end

    end
  end
  
  # 以下两个方法是给 redis search index 用
  def avatar_small
    self.avatar.small.url
  end
  def avatar_small_changed?
    self.avatar_changed?
  end

  # 用户评分，暂时方案
  def score
    self.answers_count + self.follower_ids.count * 2
  end
  def score_changed?
    self.answers_count_changed?
  end
  
  redis_search_index(:title_field => :name, 
										 :prefix_index_enable => true,
                     :ext_fields => [:id, :slug,:avatar_small,:tagline, :score])
                     #Workaround by PSVR
                     #https://github.com/huacnlee/redis-search/pull/3

  # after_create :redis_search_index_create
  # 敏感词验证
  after_create Proc.new{
    # if(u = User.where(email:'angela.cai@zhaopin.com.cn').first)
    #   self.follow(u)
    # end
  }
  after_create Proc.new{
    # User.where(:will_autofollow.ne=>nil).each{ |user|
    #   self.follow(user,true)
    # }
    # Topic.where(:will_autofollow.ne=>nil).each{ |topic|
    #   self.follow_topic(topic,true)
    # }
    # Ask.where(:will_autofollow.ne=>nil).each{ |ask|
    #   self.follow_ask(ask,true)
    # }
  }
  before_validation :check_spam_words
  def check_spam_words
    if self.spam?("tagline")
      return false
    end
    if self.spam?("name")
      return false
    end
    if self.spam?("slug")
      return false
    end
    if self.spam?("bio")
      return false
    end
  end

  before_save :downcase_email
  def self.find_for_authentication(conditions) 
    conditions[:email].try(:downcase!)
    super
  end

  def self.find_or_initialize_with_errors(required_attributes, attributes, error=:invalid)
    attributes[:email].try(:downcase!)
    super
  end

  def downcase_email
    self.email.downcase!
  end

  def password_required?
    !persisted? || password.present? || password_confirmation.present?
  end
  
  mount_uploader :avatar, AvatarUploader

  def self.create_from_hash(auth)  
		user = User.new
		user.name = auth["user_info"]["name"]  
		user.email = auth['user_info']['email']
    if user.email.blank?
      user.errors.add("Email","三方网站没有提供你的Email信息，无法直接注册。")
      return user
    end
		user.save
		user
  end  

  before_create :auto_slug
  # 此方法用于处理开始注册是自动生成 slug, 因为没表单,只能自动
  def auto_slug
    if self.slug.blank?
      if !self.email.blank?
        self.slug = self.email.split("@")[0]
self.slug=self.slug.split('.').join('-')
        self.slug = self.slug.safe_slug
      end
      # 如果 slug 被 safe_slug 后是空的,就用 id 代替
      if self.slug.blank?
        self.slug = self.id.to_s
      end
    else
      self.slug = self.slug.safe_slug
    end

    # 防止重复 slug
    old_user = User.find_by_slug(self.slug)
    if !old_user.blank? and old_user.id != self.id
      self.slug = self.id.to_s
    end
  end

  def auths
    self.authorizations.collect { |a| a.provider }
  end

  def self.find_by_slug(slug)
    first(:conditions => {:slug => slug})
  end

  # 不感兴趣点评
  def ask_muted?(ask_id)
    self.muted_ask_ids.include?(ask_id)
  end
  
  def ask_followed?(ask)
    self.followed_ask_ids.include?(ask.id)
  end
  
  def followed?(user)
    self.following_ids.include?(user.id)
  end
  
  def topic_followed?(topic)
    self.followed_topic_ids.include?(topic.id)
  end
  
  def mute_ask(ask_id)
    self.muted_ask_ids ||= []
    return if self.muted_ask_ids.index(ask_id)
    self.muted_ask_ids << ask_id
    self.save
  end
  
  def unmute_ask(ask_id)
    self.muted_ask_ids.delete(ask_id)
    self.save
  end
  
  def follow_ask(ask,nolog=false)
    ask.followers << self
    ask.save
    
    insert_follow_log("FOLLOW_ASK", ask) unless nolog
  end
  
  def unfollow_ask(ask)
    self.followed_asks.delete(ask)
    self.save
    
    ask.followers.delete(self)
    ask.save
    
    insert_follow_log("UNFOLLOW_ASK", ask)
  end
  
  def follow_topic(topic,nolog=false)
    # return if topic.follower_ids.include? self.id
    if self.is_expert
      self.tags||=[]
      self.tags << topic.name unless self.tags.include?(topic.name)
    end
    topic.followers << self
    topic.followers_count_changed = true
    topic.save

    # 清除推荐话题
    UserSuggestItem.delete(self.id, "Topic", topic.id)
    
    insert_follow_log("FOLLOW_TOPIC", topic) unless nolog
  end
  
  def unfollow_topic(topic,withlog=true)
    self.followed_topics.delete(topic)
    self.save
    
    topic.followers.delete(self)
    topic.followers_count_changed = true
    topic.save
    
    insert_follow_log("UNFOLLOW_TOPIC", topic) if withlog
  end
  
  def follow(user,nolog=false)
    user.followers << self
    user.save

    # 清除推荐话题
    UserSuggestItem.delete(self.id, "User", user.id)

    # 发送被 Follow 的邮件
    UserMailer.deliver_delayed(UserMailer.be_followed(user.id,self.id))
    
    insert_follow_log("FOLLOW_USER", user) unless nolog
  end
  
  def unfollow(user)
    self.following.delete(user)
    self.save
    
    user.followers.delete(self)
    user.save
    
    insert_follow_log("UNFOLLOW_USER", user)
  end

  # 感谢回答
  def thank_answer(answer)
    self.thanked_answer_ids ||= []
    return true if self.thanked_answer_ids.index(answer.id)
    self.thanked_answer_ids << answer.id
    self.save

    insert_follow_log("THANK_ANSWER", answer, answer.ask)
  end

  # 软删除
  # 只是把用户信息修改了
  def soft_delete
    # assuming you have deleted_at column added already
    return false if self.deleted == 1
    self.deleted = 1
    self.name = "#{self.name}[已注销]"
    self.email = "#{self.id}@zheye.org"
    self.slug = "#{self.id}"
    self.save
  end
  
  # 我的通知
  def unread_notifies
    notifies = {}
    notifications = self.notifications.unread.includes(:log).desc('created_at')
    notifications.each do |notify|
      notifies[notify.target_id] ||= {}
      notifies[notify.target_id][:items] ||= []
      
      case notify.action
      when "FOLLOW" then notifies[notify.target_id][:type] = "USER"
      when "THANK_ANSWER" then
        notifies[notify.target_id][:type] = "THANK_ANSWER"
      when "INVITE_TO_ANSWER" then notifies[notify.target_id][:type] = "INVITE_TO_ANSWER"
      when "NEW_TO_USER" then notifies[notify.target_id][:type] = "ASK_USER"
      else  
        notifies[notify.target_id][:type] = "ASK"
      end
      if "THANK_ANSWER"==notify.action
        if answer = Answer.find(notify.target_id)
          if ask=answer.ask
            notifies[ask.id]||={}
            notifies[ask.id][:items]||=[]
            notifies[ask.id][:items]<<notify
          end
        end
      else
        notifies[notify.target_id][:items] << notify
      end
    end
    
    [notifies, notifications]
  end

  # 推荐给我的人或者话题
  def suggest_items
    return UserSuggestItem.gets(self.id, :limit => 6)
  end
  
  # 刷新推荐的人
  def refresh_suggest_items
    related_people = self.followed_topics.inject([]) do |memo, topic|
      memo += topic.followers
    end.uniq
    related_people = related_people - self.following - [self] if related_people
    
    related_topics = self.following.inject([]) do |memo, person|
      memo += person.followed_topics
    end.uniq
    related_topics -= self.followed_topics if related_topics
    
    items = related_people + related_topics
    # 存入 Redis
    saved_count = 0
    # 先删除就的缓存
    UserSuggestItem.delete_all(self.id)
    mutes = UserSuggestItem.get_mutes(self.id)
    items.shuffle.each do |item|
      klass = item.class.to_s
      # 跳过 mute 的信息
      next if mutes.include?({"type" => klass, "id" => item.id.to_s})
      # 跳过删除的用户
      next if klass == "User" and item.deleted == 1
      usi = UserSuggestItem.new(:user_id => self.id, 
                                :type => klass,
                                :id => item.id)
      if usi.save
        saved_count += 1
      end
    end
    saved_count
  end

include BaseModel
#PSVR>
# autoindex issue workarounds
def redis_search_index_update
  if self.redis_search_index_need_reindex or self.new_record?
    self.redis_search_index_create
  end
end
def redis_search_index_need_reindex
  true
end
def self.cached_count
  return Rails.cache.fetch("users/count",:expires_in => 1.hours) do
    self.count
  end
end















  protected
  
    def insert_follow_log(action, item, parent_item = nil)
      begin
log = UserLog.where(:user_id=>self.id,:action=>action,:created_at.gt=>1.hours.ago).first
if log
  log.target_ids ||= []
  log.target_ids.delete(item.id)
  log.target_ids << item.id
p '----pandebug---'
p log.id
p log.target_ids
p '----pandebug---'
  log.save
else

        log = UserLog.new
        log.user_id = self.id
        log.title = self.name
        log.target_id = item.id
        log.target_ids = [item.id]
        log.action = action
        if parent_item.blank?
          log.target_parent_id = item.id
          log.target_parent_title = item.is_a?(Ask) ? item.title : item.name
        else
          log.target_parent_id = parent_item.id
          log.target_parent_title = parent_item.title
        end
        log.diff = ""
        log.save
end
      rescue Exception => e
        
      end
    end

end
