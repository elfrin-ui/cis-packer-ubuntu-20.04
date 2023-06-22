#!/bin/bash -eux

export DEBIAN_FRONTEND=noninteractive
export HISTSIZE=0
export HISTFILESIZE=0

systemd-tmpfiles --clean
systemd-tmpfiles --remove

rm -rvf /etc/ansible/*

# Uninstall Ansible and remove PPA.
apt -y remove --purge ansible git
apt-add-repository --remove ppa:ansible/ansible

#  Blank netplan machine-id (DUID) so machines get unique ID generated on boot.
truncate -s 0 /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id

# Delete unneeded files.
rm -vf /home/ubuntu/*.sh
rm -rvf /home/ubuntu/packer-provisioner-ansible-local

apt -y autoremove;
apt -y clean;

# accidentally remove cracklib file if execute
#find /var/cache -type f -exec rm -rvf {} \;

find /var/log -type f -exec truncate --size=0 {} \;

find /home -type d -name '.ansible' -exec rm -rvf {} \; || true

rm -rvf /etc/ansible

rm -rvf /tmp/* /var/tmp/* 

rm -vf /var/lib/systemd/random-seed

rm -vf /root/.wget-hsts

rm -rvf /root/*.*

# resolve to CIS control 4.2.3
find /var/log/installer/ -type l -exec rm -rvf {} \;

# Force Change password next login
passwd --expire ubuntu

rm -vf /etc/sudoers.d/ubuntu

# Zero out the rest of the free space using dd, then delete the written file.
count=$(df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}')
count=$((count-1))

dd if=/dev/zero of=/whitespace bs=1M count=$count || echo "dd exit code $? is suppressed";
rm -f /whitespace

count=$(df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}')
count=$((count-1))

dd if=/dev/zero of=/boot/whitespace bs=1M count=$count || echo "dd exit code $? is suppressed";
rm -f /boot/whitespace

# Add `sync` so Packer doesn't quit too early, before the large file is deleted.
sync

export HISTSIZE=0
