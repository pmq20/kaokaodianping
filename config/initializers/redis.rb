require "redis"
require "redis-search"
require "redis-namespace"
require "redis/objects"

#1.global
redis_config = YAML.load_file("#{Rails.root}/config/redis.yml")[Rails.env]
$redis = Redis.new(:host => redis_config[:host],:port => redis_config[:port])
$redis.select("0")
#2.redis-search
redis_search = Redis.new(:host => redis_config[:host],:port => redis_config[:port])
redis_search.select("2")
Redis::Search.configure do |config|
  config.redis = redis_search
	config.complete_max_length = 30
  config.pinyin_match = true
end
#3.resque
Resque.redis = Redis.new(:host => redis_config[:host],:port => redis_config[:port])
Resque.redis.select("3")
Resque.redis.namespace = "resque:kkdp"
#4.redis-objects
Redis::Objects.redis = Redis.new(:host => redis_config['host'], :port => redis_config['port'])
require "topic"
