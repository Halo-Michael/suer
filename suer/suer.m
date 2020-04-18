int main(int argc, const char **argv, const char **envp) {
    if (getuid() != 0) {
        setuid(0);
    }

    if (getgid() != 0) {
        setgid(0);
    }

    if (getuid() != 0 || geteuid() != 0 || getgid() != 0) {
        NSMutableArray *errors = [NSMutableArray array];
        if (getuid() != 0 || geteuid() != 0){
            [errors addObject:@"Can't set uid as 0.\n"];
        }
        if (getgid() != 0){
            [errors addObject:@"Can't set gid as 0.\n"];
        }
        NSString *error = [errors componentsJoinedByString:@""];
        printf("%s", [error UTF8String]);
        return 1;
    }

    NSMutableArray *args = [[[NSProcessInfo processInfo] arguments] mutableCopy];
    [args removeObjectAtIndex:0];
    NSString *command = [args componentsJoinedByString:@" "];

    int ret = system([command UTF8String]);

	return ret;
}
