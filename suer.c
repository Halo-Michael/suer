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

    char *command[argc];
    for (int i = 0; i < argc - 1; i++) {
        command[i] = argv[i + 1];
    }
    command[argc - 1] = NULL;

    execvp(command[0], command);

    perror(command[0]);
    return -1;
}
