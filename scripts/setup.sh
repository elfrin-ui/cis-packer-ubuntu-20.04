#!/bin/bash -eux

export DEBIAN_FRONTEND=noninteractive
export HISTSIZE=0
export HISTFILESIZE=0

SFSTAB=/etc/fstab
SED=`which sed`

# Disable daily apt unattended updates.
echo 'APT::Periodic::Enable "0";' >> /etc/apt/apt.conf.d/10periodic

# Filesystem Attributes
if [ $(grep " \/sys ext" ${SFSTAB} | grep -c "nosuid") -eq 0 ]; then
        MNT_OPTS=$(grep " \/sys ext" ${SFSTAB} | awk '{print $4}')
        ${SED} -i "s/\( \/sys.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${SFSTAB}
fi
if [ $(grep " \/boot ext" ${SFSTAB} | grep -c "nosuid") -eq 0 ]; then
        MNT_OPTS=$(grep " \/boot ext" ${SFSTAB} | awk '{print $4}')
        ${SED} -i "s/\( \/boot.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${SFSTAB}
fi
if [ $(grep " \/usr ext" ${SFSTAB} | grep -c "nodev") -eq 0 ]; then
        MNT_OPTS=$(grep " \/usr ext" ${SFSTAB} | awk '{print $4}')
        ${SED} -i "s/\( \/usr.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${SFSTAB}
fi
if [ $(grep " \/home ext" ${SFSTAB} | grep -c "nodev") -eq 0 ]; then
        MNT_OPTS=$(grep " \/home ext" ${SFSTAB} | awk '{print $4}')
        ${SED} -i "s/\( \/home.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${SFSTAB}
fi
if [ $(grep " \/export\/home ext" ${SFSTAB} | grep -c "nodev") -eq 0 ]; then
        MNT_OPTS=$(grep " \/export\/home ext" ${SFSTAB} | awk '{print $4}')
        ${SED} -i "s/\( \/export\/home.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${SFSTAB}
fi
if [ $(grep " \/usr\/local ext" ${SFSTAB} | grep -c "nodev") -eq 0 ]; then
        MNT_OPTS=$(grep " \/usr\/local ext" ${SFSTAB} | awk '{print $4}')
        ${SED} -i "s/\( \/usr\/local.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${SFSTAB}
fi
if [ $(grep " \/dev\/shm " ${SFSTAB} | grep -c "nodev") -eq 0 ]; then
        MNT_OPTS=$(grep " \/dev\/shm " ${SFSTAB} | awk '{print $4}')
        ${SED} -i "s/\( \/dev\/shm.*${MNT_OPTS}\)/\1,nodev,noexec,nosuid/" ${SFSTAB}
fi
if [ $(grep " \/tmp ext" ${SFSTAB} | grep -c "nodev") -eq 0 ]; then
        MNT_OPTS=$(grep " \/tmp ext" ${SFSTAB} | awk '{print $4}')
        ${SED} -i "s/\( \/tmp.*${MNT_OPTS}\)/\1,nodev,nosuid,noexec/" ${SFSTAB}
fi
if [ $(grep " \/var\/tmp ext" ${SFSTAB} | grep -c "nodev") -eq 0 ]; then
        MNT_OPTS=$(grep " \/var\/tmp ext" ${SFSTAB} | awk '{print $4}')
        ${SED} -i "s/\( \/var\/tmp.*${MNT_OPTS}\)/\1,nodev,nosuid,noexec/" ${SFSTAB}
fi
if [ $(grep " \/var\/log ext" ${SFSTAB} | grep -c "nodev") -eq 0 ]; then
        MNT_OPTS=$(grep " \/var\/log ext" ${SFSTAB} | awk '{print $4}')
        ${SED} -i "s/\( \/var\/log.*${MNT_OPTS}\)/\1,nodev,nosuid,noexec/" ${SFSTAB}
fi
if [ $(grep " \/var\/log\/audit ext" ${SFSTAB} | grep -c "nodev") -eq 0 ]; then
        MNT_OPTS=$(grep " \/var\/log\/audit ext" ${SFSTAB} | awk '{print $4}')
        ${SED} -i "s/\( \/var\/log\/audit.*${MNT_OPTS}\)/\1,nodev,nosuid,noexec/" ${SFSTAB}
fi
if [ $(grep " \/var ext" ${SFSTAB} | grep -c "nodev") -eq 0 ]; then
        MNT_OPTS=$(grep " \/var ext" ${SFSTAB} | awk '{print $4}')
        ${SED} -i "s/\( \/var ext.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${SFSTAB}
fi
if [ $(grep " \/var\/www ext" ${SFSTAB} | grep -c "nodev") -eq 0 ]; then
        MNT_OPTS=$(grep " \/var\/wwww ext" ${SFSTAB} | awk '{print $4}')
        ${SED} -i "s/\( \/var\/www.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${SFSTAB}
fi
if [ $(grep " \/opt ext" ${SFSTAB} | grep -c "nodev") -eq 0 ]; then
        MNT_OPTS=$(grep " \/opt ext" ${SFSTAB} | awk '{print $4}')
        ${SED} -i "s/\( \/opt.*${MNT_OPTS}\)/\1,nodev,nosuid/" ${SFSTAB}
fi
echo -e "tmpfs /dev/shm tmpfs defaults,noexec,nodev,nosuid,seclabel 0 0" >> /etc/fstab

## set up a systemd service unit in to which any boot additions are required 
## (e.g. cis Ubuntu 20.04 1.1.0 4.2.3)
#
cat << 'EOF' | sudo tee -a /etc/systemd/system/base-boot.service
################################################################################
# base-boot.service
#
# This service unit is for additional startup services required on boot
# By @ml4
# Licensed under the MIT licence.
#
################################################################################
[Unit]
Description=Runs /usr/local/bin/base-boot.sh
[Service]
ExecStart=/usr/local/bin/base-boot.sh
[Install]
WantedBy=multi-user.target
EOF

cat << 'EOF' | sudo tee -a /usr/local/bin/base-boot.sh
#!/bin/bash

## ensure /var/logs are only readable by root
#
sudo find /var/log -type f -exec sudo chmod g-wx,o-rwx "{}" + -o -type d -exec sudo chmod g-w,o-rwx "{}" +
EOF

chown root:root /usr/local/bin/base-boot.sh
chmod 744 /usr/local/bin/base-boot.sh
systemctl daemon-reload
systemctl enable base-boot
systemctl start base-boot

# update and upgrade
sudo apt update -y && sudo apt upgrade -y
