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

RUNTIME=$1
CONTAINER=$2
DIR=$3
IP=172.17.0.2

(cd filters && make)

# make output directory
mkdir -p $DIR

# pull latest test container
docker pull $CONTAINER-legacy
docker pull $CONTAINER-nabla

# set up kernel ftrace parameters
echo "function_graph" > /sys/kernel/debug/tracing/current_tracer
echo "function-fork" > /sys/kernel/debug/tracing/trace_options
echo "noirq-info" > /sys/kernel/debug/tracing/trace_options
echo "context-info" > /sys/kernel/debug/tracing/trace_options
echo "nofuncgraph-irqs" > /sys/kernel/debug/tracing/trace_options
echo "nofuncgraph-overhead" > /sys/kernel/debug/tracing/trace_options
echo "nofuncgraph-duration" > /sys/kernel/debug/tracing/trace_options
echo "nofuncgraph-tail" > /sys/kernel/debug/tracing/trace_options
echo "funcgraph-proc" > /sys/kernel/debug/tracing/trace_options
echo "0" > /sys/kernel/debug/tracing/tracing_on
echo "" > /sys/kernel/debug/tracing/trace
echo "## set up kernel ftrace parameters"

# run service
case $RUNTIME in
    "runc")
        docker run -d --rm --name=tracetest $CONTAINER-legacy
        ;;
    "runsc")
        docker run -d --rm --runtime=runsc --name=tracetest $CONTAINER-legacy
        ;;
    "runsck")
        docker run -d --rm --runtime=runsck --name=tracetest $CONTAINER-legacy
        ;;
    "kata")
        docker run -d --rm --runtime=kata --name=tracetest $CONTAINER-legacy
        ;;
    "katafc")
        docker run -d --rm --runtime=katafc --name=tracetest $CONTAINER-legacy
        ;;
    "runnc")
        docker run -d --rm --runtime=runnc --name=tracetest $CONTAINER-nabla
        ;;
esac
echo "## running $CONTAINER on $RUNTIME"

until ping -c1 $IP > /dev/null; do :; done
sleep 5

# find the pid root (docker runtime)
PSROOT=`pstree -a -p --long \
     | grep "\-runtime\-root /var/run/docker/runtime\-$RUNTIME$" \
     | cut -f 2 -d ',' \
     | cut -f 1 -d ' '`
pstree -a -p --long $PSROOT > $DIR/pidinfo
# get all processes under the root
cat $DIR/pidinfo \
    | cut -f 2 -d ',' \
    | cut -f 1 -d ' ' \
    | sed s/\)//g \
    | sort > $DIR/root_pids
# find kernel processes that are related to them
for p in `cat $DIR/root_pids`; do
    echo $p
    ps -auxH |grep $p | awk '{print $2}'
done | sort | uniq > $DIR/pids
ps -auxH  > $DIR/pidinfo_more

# set pids to trace
cat $DIR/pids > /sys/kernel/debug/tracing/set_ftrace_pid

# pin to core 0 so that we don't get weird core-switching artifacts in
# the trace
for p in `cat $DIR/pids`; do
    taskset -p 0x1 $p
done
sleep 5

echo "## tracing pids under $PSROOT"

# start the trace
echo "1" > /sys/kernel/debug/tracing/tracing_on
echo "## started tracing"

# offer load
case $CONTAINER in
    "nablact/python-tornado")
        for ((i=0;i<300;i++)); do
            sleep .1
            curl $IP:5000
        done
        ;;
    "nablact/redis-test")
        for ((i=0;i<300;i++)); do
            sleep .1
            redis-cli -h $IP -p 6379 set foo$i bar$i
        done
        ;;
    "nablact/node-express")
        for ((i=0;i<300;i++)); do
            sleep .1
            curl $IP:8080
        done
        ;;
esac
echo "## finished offering load"

# stop tracing and copy trace to directory
echo "0" > /sys/kernel/debug/tracing/tracing_on
cat /sys/kernel/debug/tracing/trace > $DIR/trace
echo "## copied trace to directory"

# kill the container
docker kill tracetest
echo "## killed container"

# process the data
for p in `cat $DIR/pids`; do
    cat $DIR/trace \
        | grep $p \
        | grep -v "=>" \
        | tee $DIR/$p.raw \
        | cut -f 2 -d '|' \
        | filters/filter-start \
        | tee $DIR/$p.filt-s \
        | filters/filter-errors \
        | tee $DIR/$p.filt-se \
        | filters/filter-interrupts \
        | tee $DIR/$p.filt-sei \
        | sort | uniq \
        | grep -v "}" \
        | cut -f 1 -d '(' \
        | awk '{print $1}' \
        | uniq \
        | tee $DIR/$p.list
done | sort |uniq > $DIR/trace.list

echo "## processed data"
