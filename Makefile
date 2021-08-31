#!/usr/bin/env nix-shell
#!nix-shell -i "make -f" -p gnumake qemu clang-tools

labnet: labnet.o

.PHONY: test
test: labnet
	./$< ./start-qemu.sh

.PHONY: format
format:
	clang-format -i labnet.c
