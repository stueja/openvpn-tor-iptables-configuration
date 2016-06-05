#!/bin/bash
iptables -A FORWARD -s 10.10.0.0/24 -i tun+ -o eth0 -j ACCEPT
iptables -A POSTROUTING -s 10.10.0.0/24 -o eth0 -j MASQUERADE

