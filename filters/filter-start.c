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

int main(int argc, char **argv) {
    int started = 0;
    char *line;

    while ((line = fgets(buf, BUFLEN, stdin)) != NULL) {

        if (!started) {
            int i = -1;
            while(line[++i] == ' ')
                ;

            /* we don't start until we see the first system call,
             * vcpu_enter_guest (for VMs), or kthread_should_stop (for
             * kernel processes) */
            if (!strncmp(line + i, "SyS", 3)
                || !strncmp(line + i, "sys", 3)
                || !strncmp(line + i, "do_syscall", 10)
                || !strncmp(line + i, "kthread_should_stop", 19)
                || !strncmp(line + i, "vcpu_enter_guest", 16))
                started = 1;
            else
                continue;
        }

        printf("%s", line);
    }
    
    return 0;
}
