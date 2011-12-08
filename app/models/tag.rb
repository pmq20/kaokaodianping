require 'chinese_pinyin'
class Tag
  include Mongoid::Document
  include Mongoid::Timestamps
  include Redis::Search
  field :topics_count, :type => Integer, :default => 0

  field :name
  field :pinyin
  before_save Proc.new{
    self.pinyin = Pinyin.t(self.name)
  }
  def topics
    Topic.any_in(:tags => [self.name])
  end
  def more
    ret=self.topics.collect(&:tags).inject([]){|s,i| s+i}.uniq
    ret.delete(self.name)
    ret
  end
  # make sure tags exists or be made exists
  def self.save_tags(tags, current_user_id=nil)
    new_tags = []
    tags.each do |item|
      tag = Tag.where(name:item.strip).first
      # find_or_create_by(:name => item.strip)
      if tag.nil?
        tag = create(:name => item.strip)
        # if current_user_id
        #   begin
        #     log = TopicLog.new
        #     log.user_id = current_user_id
        #     log.title = topic.name
        #     log.topic = topic
        #     log.action = "NEW"
        #     log.diff = ""
        #     log.save
        #   rescue Exception => e
        #     Rails.logger.warn { "Topic save_topics failed! #{e}" }
        #   end
        # end
      end
      #at this point, `tag` must points to something
      new_tags << tag.name
    end
    new_tags
  end
end
