#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/errno.h>
#include <unistd.h>

void usage() {
    printf("usage: suer [command]\n");
}

int main(int argc, char *argv[]) {
    int ret = 0;
    if (getuid() && setuid(0))
        ret += 1;
    if (getgid() && setgid(0))
        ret += 2;
    if (ret) {
        if (ret & 1)
            printf("Can't set uid as 0.\n");
        if (ret >> 1 & 1)
            printf("Can't set gid as 0.\n");
        return ret;
    }

    if (argc == 1) {
        usage();
        return 4;
    }

    execvp(argv[1], argv + 1);

    int eno = errno;
    if (eno == EPERM || eno == ENOENT || eno == ENOEXEC || eno == EACCES) {
#define POUNDBANGLIMIT 128
        char execvbuf[POUNDBANGLIMIT + 1], *ptr, *ptr2;
        int fd, ct, t0;
        if ((fd = open(argv[1], O_RDONLY|O_NOCTTY)) >= 0) {
shellexec:
            memset(execvbuf, '\0', POUNDBANGLIMIT + 1);
            ct = read(fd, execvbuf, POUNDBANGLIMIT);
            close(fd);
            if (ct >= 0) {
                if (ct >= 2 && execvbuf[0] == '#' && execvbuf[1] == '!') {
                    for (t0 = 0; t0 != ct; t0++) {
                        if (execvbuf[t0] == '\n')
                            break;
                    }
                    if (t0 == ct)
                        printf("%s: bad interpreter: %s: %d\n", argv[1], execvbuf + 2, eno);
                    else {
                        execvbuf[t0] = '\0';
                        for (ptr = execvbuf + 2; *ptr && *ptr == ' '; ptr++);
                        for (ptr2 = ptr; *ptr && *ptr != ' '; ptr++);
                        if (*ptr) {
                            *ptr = '\0';
                            argv[-1] = ptr2;
                            argv[0] = ptr + 1;
                            execv(ptr2, argv - 1);
                        } else {
                            argv[0] = ptr2;
                            execv(ptr2, argv);
                        }
                    }
                } else {
                    for (t0 = 0; t0 != ct; t0++) {
                        if (!execvbuf[t0])
                            break;
                    }
                    if (t0 == ct) {
                        argv[0] = "sh";
                        execvp("sh", argv);
                    }
                }
            }
        } else {
            char *envPath = getenv("PATH");
            if (envPath != NULL) {
                char *paths = (char *)malloc((strlen(envPath) + 1) * sizeof(char));
                char *pPaths = paths;
                strcpy(paths, envPath);
                unsigned long length = strlen(argv[1]);
                char *p;
                while ((p = strsep(&paths, ":")) != NULL) {
                    char *shellPath = (char *)calloc(strlen(p) + length + 2, sizeof(char));
                    *(char *)(strcpy(shellPath, p) + strlen(p)) = '/';
                    strcat(shellPath, argv[1]);
                    if ((fd = open(shellPath, O_RDONLY|O_NOCTTY)) >= 0) {
                        free(shellPath);
                        free(pPaths);
                        goto shellexec;
                    }
                    free(shellPath);
                }
                free(pPaths);
            }
        }
    }

    errno = eno;
    perror(argv[1]);
    return -1;
}
