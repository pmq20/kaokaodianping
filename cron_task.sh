#!/bin/bash
export PATH=$PATH:/usr/local/ruby/bin
cd /var/www/html/kkdp
/usr/local/ruby/bin/bundle exec rake mail:sendpack
/usr/local/ruby/bin/bundle exec rake mail:sendpack_expert
/usr/local/ruby/bin/bundle exec rake search:index
