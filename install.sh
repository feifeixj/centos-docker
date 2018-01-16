#!/bin/bash
sudo yum remove docker \
                  docker-common \
                  docker-selinux \
                  docker-engine
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2        
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
sudo yum-config-manager --enable docker-ce-edge
sudo yum-config-manager --disable docker-ce-edge
sudo yum -y install docker-ce
sudo systemctl enable docker
sudo systemctl start docker
sudo docker run hello-world

#开启docker socket的端口
sourceStr="ExecStart=/usr/bin/dockerd"
endStr="ExecStart=/usr/bin/dockerd -H unix:///var/run/docker.sock -H tcp://0.0.0.0:2376"
sed -i "s#$sourceStr#$endStr#g" /lib/systemd/system/docker.service  
sudo systemctl daemon-reload     
sudo systemctl restart docker 

#修改firewall 开启端口允许端口访问（以后程序在本机可以改掉）
#set port 8080 open 
firewall-cmd  --zone=public --add-port=2376/tcp --permanent
firewall-cmd --reload

# 解决WARNING: IPv4 forwarding is disabled. Networking will not work.
sed -i '$a\net.ipv4.ip_forward=1' /usr/lib/sysctl.d/00-system.conf
systemctl restart network
sysctl net.ipv4.ip_forward
