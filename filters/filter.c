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
    int bracket = 0;
    int started = 0;
    char *line;

    while ((line = fgets(buf, BUFLEN, stdin)) != NULL) {
        
        if (!started) {
            /* we don't start until we see the first system call */
            int i = -1;
            while(line[++i] == ' ')
                ;

            if (strncmp(line + i, "SyS", 3) && strncmp(line + i, "sys", 3))
                continue;
            
            started = 1;
        }


        if (bracket == 0) {
            if (check_for_interrupts(line)) {
                bracket = 1;
                continue;
            }
        }
            
        if (bracket > 0) {
            if (strchr(line, '{'))
                bracket++;
            else if (strchr(line, '}'))
                bracket--;
            continue;
        }
        
        printf("%s", line);
    }
    
    return 0;
}
