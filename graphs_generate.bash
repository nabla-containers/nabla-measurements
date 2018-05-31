#!/bin/bash

APPS="node_auth python_tornado redis_test"
SYSTEMS="runc runsc"

# for a in $APPS; do
#     for s in $SYSTEMS; do
#         for i in 1 2 3 4 5; do
#             sudo ./runtest.bash $s $a results/$s-$a-$i;
#         done;
#     done;
# done

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
    cat results/summary-ftrace.dat | grep $g > results/summary-ftrace-$g.dat
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
    cat results/summary-syscalls.dat | grep $g > results/summary-syscalls-$g.dat
done

gnuplot graphs.plot
