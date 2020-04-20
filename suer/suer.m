int main(int argc, const char **argv, const char **envp) {
    if (getuid() != 0) {
        setuid(0);
    }

    if (getgid() != 0) {
        setgid(0);
    }

    if (getuid() != 0 || geteuid() != 0 || getgid() != 0) {
        NSString *error = @"";
        if (getuid() != 0 || geteuid() != 0){
            error = [error stringByAppendingString:@"Can't set uid as 0.\n"];
        }
        if (getgid() != 0){
            error = [error stringByAppendingString:@"Can't set gid as 0.\n"];
        }
        printf("%s", [error UTF8String]);
        return 1;
    }

    NSMutableArray *args = [NSMutableArray array];
    for (int i = 1; i < argc; i++) {
        if ([[NSString stringWithFormat:@"%s", argv[i]] containsString:@" "] || [[NSString stringWithFormat:@"%s", argv[i]] containsString:@"$"] || [[NSString stringWithFormat:@"%s", argv[i]] containsString:@"`"]) {
            [args addObject:[NSString stringWithFormat:@"'%s'", argv[i]]];
        } else if ([[NSString stringWithFormat:@"%s", argv[i]] containsString:@"\""] || [[NSString stringWithFormat:@"%s", argv[i]] containsString:@"'"] || [[NSString stringWithFormat:@"%s", argv[i]] containsString:@"\\"] || [[NSString stringWithFormat:@"%s", argv[i]] containsString:@"*"]) {
            NSString *thisarg = @"";
            for (int j = 0; j < strlen(argv[i]); j++) {
                if (argv[i][j] == '\"' || argv[i][j] == '\'' || argv[i][j] == '\\' || argv[i][j] == '*'){
                    thisarg = [thisarg stringByAppendingString:@"\\"];
                    thisarg = [thisarg stringByAppendingFormat:@"%c", argv[i][j]];
                } else {
                    thisarg = [thisarg stringByAppendingFormat:@"%c", argv[i][j]];
                }
            }
            [args addObject:thisarg];
        } else {
            [args addObject:[NSString stringWithFormat:@"%s", argv[i]]];
        }
    }

    NSString *command = [args componentsJoinedByString:@" "];

    int status = system([command UTF8String]);
    return WEXITSTATUS(status);
}
