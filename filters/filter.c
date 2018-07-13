/* 
 * Copyright (c) 2018 Contributors as noted in the AUTHORS file
 *
 * Permission to use, copy, modify, and/or distribute this software
 * for any purpose with or without fee is hereby granted, provided
 * that the above copyright notice and this permission notice appear
 * in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL
 * WARRANTIES WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE
 * AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT, INDIRECT, OR
 * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS
 * OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT,
 * NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN
 * CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#include <stdio.h>
#include <string.h>

#define BUFLEN 4096
char buf[BUFLEN];

int check_for_interrupts(char *line) {
    return (strstr(line, "smp_irq_work_interrupt")
            || strstr(line, "smp_apic_timer_interrupt")
            || strstr(line, "smp_reschedule_interrupt")
            || strstr(line, "smp_call_function_single_interrupt")
            || strstr(line, "exit_to_usermode_loop")
            || strstr(line, "__softirqentry_text_start")
            || strstr(line, "run_timer_softirq")
            || strstr(line, "printk_nmi_enter")
            || strstr(line, "printk_nmi_exit")
            || strstr(line, "do_async_page_fault")
            || strstr(line, "__entry_text_end")
            || strstr(line, "do_softirq")
            || strstr(line, "do_general_protection")
            || strstr(line, "__do_page_fault")
            );
}

int main(int argc, char **argv) {
    int filtering = 0;
    int filtering_indent = 0;
    int started = 0;
    char *line;

    while ((line = fgets(buf, BUFLEN, stdin)) != NULL) {

        if (!started) {
            int i = -1;
            while(line[++i] == ' ')
                ;

            /* we don't start until we see the first system call */
            /* or we see kthread_should_stop (for kernel processes) */
            if (!strncmp(line + i, "SyS", 3)
                || !strncmp(line + i, "sys", 3)
                || !strncmp(line + i, "do_syscall", 10)
                || !strncmp(line + i, "kthread_should_stop", 19))
                started = 1;
            else
                continue;
        }

        /* checking for brackets (e.g., { ... } ) is a bit fragile
         * because ftrace can mislabel one.  However, ftrace's
         * indentation is more reliable. */
        int indent = -1;
        while(line[++indent] == ' ')
            ;
        if (!filtering) {
            if (check_for_interrupts(line)) {
                filtering = 1;
                filtering_indent = indent;
                continue;
            }
        }

        if (filtering) {
            if (indent == filtering_indent)
                filtering = 0;
            if (indent >= filtering_indent)
                continue;
        }

        printf("%s", line);
    }
    
    return 0;
}
