namespace :tmp do
  task :xiaohao => :environment do
    0.upto(999) do |i|
      e1 = "xxx#{i}@xxx.com"
      e2 = "yyy#{i}@yyy.com"
      u1 = User.where(email:e1).first
      u2 = User.where(email:e2).first
      u1.xiaohao = true
      u2.xiaohao = true
      u1.save!
      u2.save!
    end
  end
end