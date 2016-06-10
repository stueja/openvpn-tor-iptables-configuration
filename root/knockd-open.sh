#!/bin/bash
iptables -I INPUT -s $1 -p tcp --dport 1022 -j ACCEPT
iptables -I OUTPUT -d $1 -p tcp --sport 1022 -j ACCEPT
