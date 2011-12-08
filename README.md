# 考考点评

## 简单部署指南
```
sudo mongod --dbpath /kkdata --logpath /var/log/mongod.log --logappend --fork

sudo redis-server config/redis.conf

bundle exec thin start -e production -d --log ./log/thin.log --port 4000

INTERVAL=5 VERBOSE=1 PIDFILE=./tmp/resque.pid BACKGROUND=yes QUEUE=* bundle exec rake environment resque:work
```

本地可以用这句：
```
bundle exec rails server thin -e development
```

-or-

```
sudo mongod --dbpath /kkdata
```

-japan-

```
sudo /home/psvr/bin/mongod  --dbpath /kkdata --logpath /var/log/mongod.log --logappend --fork
sudo redis-server config/redis.conf
mongorestore --drop
bundle exec thin start -e production -d --log ./log/thin.log --servers 1 --socket /tmp/thin.myapp.sock --chdir /home/psvr/kkdianping --pid tmp/pids/thin.pid
```

## 部署指南
基本的精灵进程是mongod和redis-server，先保证这两个进程的运行，其他的进程点评项在下文解释。

开发的时候，`foreman`可以提供很大的方便。这使得我们在开发时，想启动所有进程的时候，直接执行"foreman start"即可。

然而，真正的生产环境，需要我们对所启动进程的资源（memory usage, cpu usage, and request queue length）占用情况进行监控。因为foreman生产的进程，当它们死去时，不会被重新生产，所以我们需要启用另外的监控工具。

（1）一种方法是“蓝药丸”：负责监控各进程（例如thin的数个进程以及resque的工人进程），防止它们使用过多系统资源，当它们使用过多资源时重启它们。
或当这些进程因为某种错误死去时负责重新启动它们。

详细见
[http://asemanfar.com/Why-We-Wrote-Bluepill]


（2）另外一种方法是使用Linux原生的init和upstart工具
详细见
[http://upstart.ubuntu.com/cookbook/]

部署所需进程见Procfile


