This directory contains various filters for the ftrace traces that are
gathered in the parent directory.  The main objective is to filter out
interrupts that may do a lot of work that is not on behalf of the
process being traced.  There are currently three filters, which serve
the following purposes:

* `filter-start`: We want to avoid the case that the trace starts with
  functions that have come from the middle of interrupt routines that
  we cannot otherwise identify as such.  To do this, `filter-start`
  cuts off the beginning of the trace until it sees the first system
  call, kvm guest entry or kthread operation.

* `filter-errors`: Sometimes ftrace assigns a function to the wrong
  process.  We have found indentation is a relatively good heuristic
  to try to filter out those errors.  Note: these types of errors
  happen far less when the processes are pinned to a single core.

* `filter-interrupts`: We use the function-graph plugin for ftrace to
  produce traces that allow us to see what child functions should be
  removed if a parent is removed.  We currently filter the following
  interrupt-related functions:

      smp_irq_work_interrupt
      smp_apic_timer_interrupt
      smp_reschedule_interrupt
      smp_call_function_single_interrupt
      do_softirq

To build the filters, type

    make

To run them on a trace with a single pid, use this sequence:

    cat trace | filter-start | filter-errors | filter-interrupts

See `runtest.bash` for a working example that uses the filters.
