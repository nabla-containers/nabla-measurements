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
