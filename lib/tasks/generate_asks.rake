# coding: utf-8
namespace :generate do
  task :asks=>:environment do
    Topic.all.each do |topic|
      topic.schools.each do |school|
        title = "[#{topic.name}] #{school}"
        criterion = {title:title,type:'学校'}
        ask = Ask.where(criterion.merge({topics:topic.name})).first
        ask ||= Ask.new(criterion)
        ask.topics.delete(topic.name)
        ask.topics << topic.name
        ask.save!
      end
      topic.courses.each do |course|
        title = "[#{topic.name}] #{course}"
        criterion = {title:title,type:'课程'}
        ask = Ask.where(criterion.merge({topics:topic.name})).first
        ask ||= Ask.new(criterion)
        ask.topics.delete(topic.name)
        ask.topics << topic.name
        ask.save!
      end
    end
  end
end