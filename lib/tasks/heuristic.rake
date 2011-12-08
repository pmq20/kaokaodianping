# require 'chinese_pinyin'
# namespace :y do
#   task :heuristics=>:environment do
#     Ask.all.each do |ask|
#       ask.search_heuristic = ask.title.split(/[\[\]]/).join('').split(/\s/).join('').strip
#       ask.search_heuristic_pinyin = Pinyin.t(ask.search_heuristic,'')
#       ask.save!
#     end
#   end
# end