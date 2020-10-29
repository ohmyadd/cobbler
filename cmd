#! /bin/bash

docker rm -f cobbler

set -ex
docker build -t cobbler .
docker run -d --name cobbler \
       -v $(pwd)/snippets:/var/lib/cobbler/snippets \
       -v $(pwd)/kickstarts:/var/lib/cobbler/kickstarts \
       -v $(pwd)/mnt:/mnt \
       -v $(pwd)/../config/cobbler.cfg:/etc/cobbler.cfg \
       -v $(pwd)/../config/network.cfg:/etc/network.cfg \
       -v $(pwd)/file:/var/www/html/file:ro \
       --net=host --privileged cobbler
#       -p 69:69/udp -p 80:80 -p 443:443 -p 25151:25151 \
#       -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
sleep 6s
docker exec cobbler /root/run.sh



docker exec cobbler cobbler system list
