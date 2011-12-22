namespace :cache do
  task :update => :environment do
    def global_topic_calculations
      $topics = Topic.all.to_a.collect{|x|[x.name,x.followers_count,Log.where(action:'ADD_TOPIC').where(:created_at.gt=>150.days.ago).where(title:x.name).count]}.sort{|x,y|
        result = x[1]<=>y[1]
        if 0==result
          result = x[2]<=>y[2]
        end
        result
      }.reverse
    end

    global_topic_calculations
    
    $asks = Ask.all.to_a.collect{|x| [x,AnswerLog.where(action:'NEW').where(:created_at.gt=>150.days.ago).where(target_parent_id:x.id).count]}.sort{|x,y|
      x[1]<=>y[1]
    }.reverse
    
    
    TopicCache.delete_all
    $topics.each_with_index do |topic,i|
      TopicCache.create!(name:topic[0],hot_rank:i,followers_count:topic[1])
    end

    AskCache.delete_all
    $asks.each_with_index do |a,i|
      ask=a[0]
      AskCache.create!(ask_id:ask.id,hot_rank:i)
    end 
    
    ExpertCache.delete_all
    User.where(:is_expert=>true).collect(&:tags).flatten.uniq.each do |tag|
      ec = ExpertCache.create!(tag:tag)
      @ask_ids = Ask.where(:topics => tag).normal.collect(&:id)
      ec.experts = User.where(:is_expert=>true).where(:tags=>tag).to_a.sort{|x,y| x.answers.any_in(:ask_id=>@ask_ids).count <=> y.answers.any_in(:ask_id=>@ask_ids).count}.reverse.collect(&:id)
      ec.save!
    end
  end
end
