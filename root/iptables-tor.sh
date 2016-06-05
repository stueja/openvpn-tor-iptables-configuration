#!/bin/bash
iptables -I OUTPUT -m conntrack --ctstate INVALID -j DROP
iptables -I OUTPUT -m state --state INVALID -j DROP
iptables -I OUTPUT ! -o lo ! -d 127.0.0.1 ! -s 127.0.0.1 -p tcp -m tcp --tcp-flags ACK,FIN ACK,FIN -j DROP
iptables -I OUTPUT ! -o lo ! -d 127.0.0.1 ! -s 127.0.0.1 -p tcp -m tcp --tcp-flags ACK,RST ACK,RST -j DROP

iptables -t nat -A PREROUTING -i tun+ -p udp --dport 53 -j REDIRECT --to-ports 5353  
iptables -t nat -A PREROUTING -i tun+ -p tcp --syn -j REDIRECT --to-ports 9040

