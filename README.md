This is a repository containing the methodology for some experiments
used to evaluate one aspect of container isolation: the attack surface
to the host kernel.  More specifically, these experiments measure how
many kernel functions are accessed by an application as it runs.

The script `runtest.bash` performs a run of a test on one of the
Docker containers that we have provided in the `docker_containers`
directory.  Currently this consists of:

* **node_auth**: a node.js express application (an auth server)
* **python_tornado**: a python tornado web server
* **redis-server**: a redis key/value server

Each run of `runtest.bash` sets up the kernel ftrace facility, runs
the container, turns on tracing for the relevant pids, offers load,
cleans up and processes the results.  The raw and processed output
ends up in a directory for later perusal.

The easiest way to replicate a test is to run commands of the form
`./runtest.bash <RUNTIME> <CONTAINER> <OUTPUT_DIR>`.  RUNTIME can
currently be `runc` (default docker) or `runsc` (gvisor) and CONTAINER
is one of those specified above.  Here are some examples:

    sudo ./runtest.bash runc python_tornado results/docker-python
    sudo ./runtest.bash runsc python_tornado results/gvisor-python


###  Technical notes

For ease of measurement, we do not measure the startup coverage of the
containers, thus we need containers that are long-running enough to
give the tracing enough time to turn on.  Partially this is because of
how we gather the relevant pids.  This is done by looking through
`pstree` for all the children of the `docker-containe` command
specifying the `-runtime-root`, which is either `runtime-runc` (in the
default case) or `runtime-runsc` (in the gvisor case).

We also process the raw traces primarily to eliminate interrupts,
which may perform work on behalf of other processes.  There are two
filtering programs, written in C, in the `filters/` directory to aid
in removing interrupt-related functions from the raw trace.
Occasionally, when encountering many context switches, ftrace seems to
mistakenly assign a function call to the wrong pid. The program
`filters/filter-errors.c` is used to identify and remove these lines.

Once filtering and processing is complete, a list of the unique
functions called should appear in `OUTPUT_DIR/trace.list`.  Counting
the lines in this file will give a count of the unique functions.
Alternately, grepping for functions starting with sys will show the
system calls (e.g., `grep -i "^sys\_"`)

### Our results

We have included some results for default docker and gvisor that were
obtained using the `graphs_generate.bash` script.

![functions](https://github.ibm.com/djwillia/ftracing/master/graph-functions.png)
![syscalls](https://github.ibm.com/djwillia/ftracing/master/graph-syscalls.png)

