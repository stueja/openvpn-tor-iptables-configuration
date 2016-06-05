#!/bin/bash
iptables -A INPUT -i eth0 -p tcp -m state --state NEW,ESTABLISHED --dport 443 -j ACCEPT
iptables -A OUTPUT -o eth0 -p tcp -m state --state ESTABLISHED --sport 443 -j ACCEPT
iptables -A INPUT -i tun+ -j ACCEPT
iptables -A OUTPUT -o tun+ -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

