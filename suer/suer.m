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
    int i = 1;
    while (i < argc) {
        if ([[NSString stringWithFormat:@"%s", argv[i]] containsString:@" "] || [[NSString stringWithFormat:@"%s", argv[i]] containsString:@"$"] || [[NSString stringWithFormat:@"%s", argv[i]] containsString:@"`"]){
            [args addObject:[NSString stringWithFormat:@"'%s'", argv[i]]];
        } else if ([[NSString stringWithFormat:@"%s", argv[i]] containsString:@"\""] || [[NSString stringWithFormat:@"%s", argv[i]] containsString:@"'"] || [[NSString stringWithFormat:@"%s", argv[i]] containsString:@"\\"] || [[NSString stringWithFormat:@"%s", argv[i]] containsString:@"*"]){
            NSString *thisarg = @"";
            int j = 0;
            while (j < strlen(argv[i])){
                if (argv[i][j] == '\"' || argv[i][j] == '\'' || argv[i][j] == '\\' || argv[i][j] == '*'){
                    thisarg = [thisarg stringByAppendingString:@"\\"];
                    thisarg = [thisarg stringByAppendingFormat:@"%c", argv[i][j]];
                } else {
                    thisarg = [thisarg stringByAppendingFormat:@"%c", argv[i][j]];
                }
                j++;
            }
            [args addObject:thisarg];
        } else {
            [args addObject:[NSString stringWithFormat:@"%s", argv[i]]];
        }
        i++;
    }

    NSString *command = [args componentsJoinedByString:@" "];

    int ret = system([command UTF8String]);
    return ret;
}
