#!/bin/sh
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -t raw -F
iptables -t raw -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT

stamp="$(date +'%Y-%m-%d-%H%M%S')"
echo $stamp > /root/iptables.revoked."$date"
logger -t iptables-revoke "$date" iptables revoked

