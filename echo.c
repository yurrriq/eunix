#include <stdio.h>
#include <getopt.h>


void usage();


int main(int argc, char *argv[])
{
    /* Flag set by '-n'. */
    int newline_flag = 1;

    int c;

    while ((c = getopt(argc, argv, "n")) != EOF) {
        switch (c) {
        case 'n':
            newline_flag = 0;
            break;
        case '?':
            usage();
            return 1;
        }
    }

    int index;

    for (index = optind; index < argc; index++) {
        printf("%s", argv[index]);
        if (index < argc - 1)
            putchar(' ');
    }

    if (newline_flag)
        putchar('\n');

    return 0;
}


void usage()
{
    printf("Usage: echo [-n] [string ...]\n");
}
