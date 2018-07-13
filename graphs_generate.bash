#!/bin/bash
# Copyright (c) 2018 Contributors as noted in the AUTHORS file
#
# Permission to use, copy, modify, and/or distribute this software
# for any purpose with or without fee is hereby granted, provided
# that the above copyright notice and this permission notice appear
# in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
# WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
# AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
# CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
# OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
# NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
# CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

APPS="node-express redis-test python-tornado"
SYSTEMS="kata runc runsc runnc runsck"

for s in $SYSTEMS; do
    for ((i=1;i<5;i++)); do
        for a in $APPS; do
            sudo ./runtest.bash $s nablact/$a results/$s-$a-$i;
        done;
    done;
done

echo "# test N min max sum mean stddev" > results/summary-ftrace.dat
for a in $APPS; do
    for s in $SYSTEMS; do
        echo -n "$s-$a ";
        for h in results/$s-$a*/trace.list; do
            cat $h | wc -l;
        done | st --no-header -d ' ';
    done;
done >> results/summary-ftrace.dat
for g in $SYSTEMS; do
    cat results/summary-ftrace.dat | grep $g- > results/summary-ftrace-$g.dat
done

echo "# test N min max sum mean stddev" > results/summary-syscalls.dat
for a in $APPS; do
    for s in $SYSTEMS; do
        echo -n "$s-$a ";
        for h in results/$s-$a*/trace.list; do
            cat $h |grep -i "^sys_" | wc -l
        done | st --no-header -d ' ';
    done;
done >> results/summary-syscalls.dat
for g in $SYSTEMS; do
    cat results/summary-syscalls.dat | grep $g- > results/summary-syscalls-$g.dat
done

gnuplot graphs.plot
