#!/bin/bash

master=$1

echo "Setting up $(hostname), master's address is ${master}.."

[[ -z $master ]] && exit 1


[[ -e /etc/yum/pluginconf.d/fastestmirror.conf ]] && rm /etc/yum/pluginconf.d/fastestmirror.conf

find /etc/yum.repos.d/ -type f -name '*.repo' -exec sed -i 's/#baseurl=/baseurl=/g' {} \;
find /etc/yum.repos.d/ -type f -name '*.repo' -exec sed -i 's/mirrorlist=/#mirrorlist=/g' {} \;

yum install -q -y git screen

wget -q https://raw.githubusercontent.com/saltstack/salt-bootstrap/stable/bootstrap-salt.sh -O /tmp/bootstrap-salt.sh

if [[ $(hostname) == saltmaster* ]]; then
  source /tmp/bootstrap-salt.sh -Z -P -A ${master} git v2015.8.3 &> /tmp/vm-bootstrap.log
  git clone -q https://github.com/bechtoldt/talk-salt-orchestration.git /srv/salt
  cd /srv/salt/
  git submodule -q update --init --recursive .
  rm /etc/salt/master
  ln -s /srv/salt/states/orchestration/files/master /etc/salt/master
  service salt-master restart
  sleep 10
  service salt-minion restart
else
  source /tmp/bootstrap-salt.sh -Z -P -A ${master} git v2015.8.3 &> /tmp/vm-bootstrap.log
fi
