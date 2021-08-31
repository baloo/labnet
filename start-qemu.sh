#!/bin/sh

set -x

ip link set lo up
ip link add br0 type bridge
ip addr add 192.168.0.1/24 dev br0

qemu-kvm -m 1G -cpu host -serial mon:stdio -net nic,model=virtio,id=net0 -net bridge,id=net0,br=br0 -nographic

