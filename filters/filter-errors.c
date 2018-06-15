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
    char *line;
    int expected_sp = 3;
    
    while ((line = fgets(buf, BUFLEN, stdin)) != NULL) {

        int sp = -1;
        while(line[++sp] == ' ')
            ;

        if (line[sp] == '}') {
            if (sp == expected_sp - 2) {
                puts(line);
                expected_sp -= 2;
            }
        } else {
            if (sp == expected_sp) {
                puts(line);
                while(line[++sp] != '\n')
                    ;
                if (line[sp - 1] == '{')
                    expected_sp += 2;
            }
        }
    }
    
    return 0;
}
