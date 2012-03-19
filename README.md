# 考考点评

http://www.kkdp.net

挑选最适合你的培训机构

## 简单部署指南
```
sudo mongod --dbpath /kkdata --logpath /var/log/mongod.log --logappend --fork

sudo redis-server config/redis.conf

bundle exec thin start -e production -d --log ./log/thin.log --port 4000

INTERVAL=5 VERBOSE=1 PIDFILE=./tmp/resque.pid BACKGROUND=yes QUEUE=* bundle exec rake environment resque:work
```

