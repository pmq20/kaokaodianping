# coding: utf-8
namespace :x do
  task :xiaoyuzhong => :environment do
    Topic.any_in(:tags=>%w(德语 法语 日语 韩语 西班牙语 意大利语 俄语 葡萄牙语)).each do |t|
      t.tags.delete('小语种')
      t.tags += ['小语种']
      t.save!
    end
  end
end