# coding: utf-8

namespace :integrity do
  task :tags=>:environment do
    # make sure tags exists or be made exists
    Topic.all.each do |topic|
      Tag.save_tags(topic.tags)
    end
  end
end
