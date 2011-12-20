# coding: utf-8

namespace :integrity do
  task :counters=>:environment do
    # if a tag has no topics, it dies
    Tag.all.each do |tag|
      tag.topics_count = Topic.where(:tags=>tag.name).count
      if(0==tag.topics_count)
        tag.delete
      else
        tag.save!
      end
    end
    #if a topic has an unexistent tag, then it is reborn
    Topic.all.each do |topic|
      Tag.save_tags(topic.tags)
      asks = Ask.where(:topics=>topic.name)
      topic.answers_count = asks.inject(0){|s,ask| s+ask.answers.count}
      topic.save!
    end
    
    User.all.each do |user|
      user.integrity_op
      user.save!
    end
    
  end
end
