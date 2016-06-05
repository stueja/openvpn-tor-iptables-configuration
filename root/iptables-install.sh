#!/bin/bash
# set policies to accept
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
# clean iptables
iptables -F
iptables -t nat -F
iptables -X
iptables -t nat -X
# allow localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT ! -i lo -s 127.0.0.0/8 -j REJECT
iptables -A OUTPUT -o lo -j ACCEPT
# allow SSH
iptables -A INPUT -i eth0 -p tcp -m state --state NEW,ESTABLISHED --dport 1022 -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp -m state --state NEW,ESTABLISHED --sport 1022 -j ACCEPT
# if you are now connected via port 22
iptables -A INPUT -i eth0 -p tcp -m state --state NEW,ESTABLISHED --dport 22 -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp -m state --state NEW,ESTABLISHED --sport 22 -j ACCEPT
# block everything else
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

