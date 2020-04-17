#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

int main()
{
    if (geteuid() != 0) {
        printf("Run this as root!\n");
        return 1;
    }

    system("chown root:wheel /usr/bin/suer");
    system("chmod 6755 /usr/bin/suer");

    return 0;
}
