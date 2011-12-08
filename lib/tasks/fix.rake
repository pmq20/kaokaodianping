# coding: utf-8
namespace :fix do
  task :fix=>:environment do
    Topic.all.each do |topic|
      if topic.tags.include?('证劵') then
        topic.tags.delete('证劵')
        topic.tags+=['证券']
        topic.save!
      end
    end
  end
end

