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
SYSTEMS="katafc kata runc runsc runnc runsck"

for s in $SYSTEMS; do
    for ((i=1;i<=10;i++)); do
        for a in $APPS; do
            sudo ./runtest.bash $s nablact/$a results/$s-$a-$i;
            sleep 5
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
done |sort >> results/summary-ftrace.dat
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
done |sort >> results/summary-syscalls.dat
for g in $SYSTEMS; do
    cat results/summary-syscalls.dat | grep $g- > results/summary-syscalls-$g.dat
done

bash ./complexity.bash

echo -n "# test " > results/summary-complexity.list.dat
echo -n "[sum: N min max sum mean stddev]" >> results/summary-complexity.list.dat
echo -n "[max: N min max sum mean stddev]" >> results/summary-complexity.list.dat
echo -n "[mean: N min max sum mean stddev]" >> results/summary-complexity.list.dat
echo    "[unknown: N min max sum mean stddev]" >> results/summary-complexity.list.dat
for a in $APPS; do
    for s in $SYSTEMS; do
        echo -n "$s-$a ";
        # sum
        for h in results/$s-$a*/complexity.list; do
            cat $h | grep -v "^#" | cut -f 4 -d ' '
        done | st --no-header -d ' ' | tr '\n' ' ';
        # max
        for h in results/$s-$a*/complexity.list; do
            cat $h | grep -v "^#" | cut -f 3 -d ' '
        done | st --no-header -d ' ' | tr '\n' ' ';
        #  mean
        for h in results/$s-$a*/complexity.list; do
            cat $h | grep -v "^#" | cut -f 5 -d ' '
        done | st --no-header -d ' ' | tr '\n' ' ';
        # unknown sum
        for h in results/$s-$a*/complexity.list; do
            cat $h | grep -v "^#" | cut -f 7 -d ' '
        done | st --no-header -d ' ';
    done;
done | sort >> results/summary-complexity.list.dat
for g in $SYSTEMS; do
    cat results/summary-complexity.list.dat | grep $g- > results/summary-complexity-list-$g.dat
done

gnuplot graphs.plot
