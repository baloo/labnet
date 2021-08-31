#!/bin/sh

set -x

ip link set lo up
ip link add br0 type bridge
ip link set br0 up
ip addr add 192.168.0.1/24 dev br0
DHCPD_PID=$(mktemp)
id
echo 8192 > /proc/sys/fs/inotify/max_user_instances
echo 524288 > /proc/sys/fs/inotify/max_user_watches
dnsmasq --leasefile-ro --dhcp-broadcast -p 0 -F 192.168.0.2,192.168.0.10,255.255.255.0,1h -M $1 --pid-file=$DHCPD_PID --listen-address=192.168.0.1 -d 2>&1 >/dev/null &

qemu-kvm -m 1G -cpu host -serial mon:stdio \
 -netdev tap,id=nd1,script="./helper.sh" \
 -device virtio-net-pci,netdev=nd1 \
 -nographic
kill $(cat $DHCPD_PID)
