#!/bin/bash

if [ $# -ne "1" ]; then
	exit 1
fi

hexdump -v -e '1/1 ",0x%02x"' $1 > "${1%.*}".hex

