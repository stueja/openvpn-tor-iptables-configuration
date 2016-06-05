#!/bin/bash
mv /etc/ssh/sshd_config /etc/ssh/sshd_config.old
cp /etc/ssh/sshd_config.orig /etc/ssh/sshd_config
systemctl restart sshd

stamp="$(date +'%Y-%m-%d-%H%M%S')"
echo $stamp > /root/sshconfig.revoked."$date"
logger -t sshconfig-revoke "$date" sshconfig revoked

