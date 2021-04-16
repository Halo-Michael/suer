#include <stdio.h>
#include <unistd.h>

void usage() {
    printf("usage: suer [command]\n");
}

int main(int argc, char *argv[]) {
    if (getuid() != 0) {
        setuid(0);
    }

    if (getgid() != 0) {
        setgid(0);
    }

    if (getuid() != 0 || geteuid() != 0 || getgid() != 0) {
        if (getuid() != 0 || geteuid() != 0) {
            printf("Can't set uid as 0.\n");
        }
        if (getgid() != 0) {
            printf("Can't set gid as 0.\n");
        }
        return 1;
    }

    if (argc == 1) {
        usage();
        return 2;
    }

    argv[argc] = NULL;
    execvp(argv[1], argv + 1);

    perror(argv[1]);
    return -1;
}
