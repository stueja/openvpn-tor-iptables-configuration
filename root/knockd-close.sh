#!/bin/bash
iptables -D INPUT -s $1 -p tcp --dport 1022 -j ACCEPT
iptables -D OUTPUT -d $1 -p tcp --sport 1022 -j ACCEPT
