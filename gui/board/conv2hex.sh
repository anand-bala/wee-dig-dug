#!/bin/bash

for a in ans/*.ans; do
	x=$(basename $a)
	set +x
	echo "$x"
	hexdump -v -e '1/1 ",0x%02x"' $a > "hex/${x%.ans}".hex
done

set -x
