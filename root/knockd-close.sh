#!/bin/bash
iptables -D INPUT -s 217.140.81.78 -p tcp --dport 1022 -j ACCEPT
iptables -D OUTPUT -d 217.140.81.78 -p tcp --sport 1022 -j ACCEPT

iptables -D INPUT -s $1 -p tcp --dport 1022 -j ACCEPT
iptables -D OUTPUT -d $1 -p tcp --sport 1022 -j ACCEPT
