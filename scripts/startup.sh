#!/bin/bash

sleep 40

sudo systemctl restart systemd-networkd.service
sleep 5

sudo systemctl start dnsmasq.service
sleep 5

sudo systemctl restart ip-rules.service
sleep 5

sudo systemctl start dnscrypt-proxy.service
sleep 5

sudo systemctl start vpn-manager.service
sleep 5

sudo systemctl start minidlna.service
sleep 5

sudo systemctl restart tc.service
sleep 5

sudo systemctl start arch-portal.service
sleep 15

sudo systemctl start caddy.service
sleep 5

sudo systemctl start wan-watcher.service
