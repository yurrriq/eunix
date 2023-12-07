#include <getopt.h>
#include <pwd.h>
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>

uid_t NO_UID = -1;

void usage();

int main(int argc, char *argv[])
{
    if (getopt(argc, argv, "") != EOF) {
        usage();
        return 1;
    }

    uid_t uid;
    struct passwd *pw;
    uid = geteuid();

    if (uid == NO_UID || !(pw = getpwuid(uid))) {
        printf("Cannot find name for user ID %lu\n", (unsigned long int)uid);
        return 1;
    }
    puts(pw->pw_name);

    return 0;
}

void usage()
{
    fprintf(stderr, "Try 'whoami --help' for more information.\n");
}
