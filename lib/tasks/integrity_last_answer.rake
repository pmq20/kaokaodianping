namespace :integrity do
  task :last_answer => :environment do
sum=0
    Ask.all.each do |a|
      an = a.answers.desc('created_at').first
next unless an
sum+=a.answers.count
      a.answered_at = an.created_at
      a.last_answer_id = an.id
      a.last_answer_user_id = an.user_id
      a.current_user_id = an.user_id
      a.save!
    end
p sum
  end
end
