#include <stdio.h>
#include <sys/types.h>
#include <pwd.h>
#include <unistd.h>
#include <getopt.h>


void usage();


int main(int argc, char *argv[])
{
    if (getopt(argc, argv, "") != EOF) {
        usage();
        return 1;
    }

    struct passwd *pw;
    uid_t uid;
    uid_t NO_UID = -1;

    uid = geteuid();

    if (uid == NO_UID || !(pw = getpwuid(uid))) {
        printf("Cannot find name for user ID %lu\n",
               (unsigned long int) uid);
        return 1;
    }
    puts(pw->pw_name);

    return 0;
}


void usage()
{
    printf("Usage: whoami\n");
}
