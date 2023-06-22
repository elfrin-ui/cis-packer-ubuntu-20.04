#!/bin/bash -eux

export DEBIAN_FRONTEND=noninteractive
export HISTSIZE=0
export HISTFILESIZE=0
export ANSIBLE_CONFIG=/var/tmp/ansible.cfg

add-apt-repository --yes ppa:ansible/ansible
apt-get --assume-yes update
apt-get --assume-yes --no-install-recommends install ansible

cd /var/tmp || exit 1

ansible-playbook -i '127.0.0.1,' -c local ./local.yml
