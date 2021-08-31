#!/usr/bin/env nix-shell
#!nix-shell -i "make -f" -p gnumake qemu "dnsmasq.overrideAttrs(old: {preBuild = ''makeFlagsArray=(\"COPTS=-DNO_INOTIFY\")'';})"
 
labnet: labnet.o

.PHONY: test
test: labnet
	unshare -f --pid -r -n -m -U --map-group=0 -S 0 --mount-proc ./start-qemu.sh http://192.168.0.1:3030/foo

.PHONY: format
format:
	clang-format -i labnet.c
