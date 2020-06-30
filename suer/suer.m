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
        NSString *arg = [[NSString alloc] initWithUTF8String:argv[i]];
        if ([arg containsString:@" "] || [arg containsString:@"$"] || [arg containsString:@"`"] || [arg containsString:@"\""] || [arg containsString:@"'"] || [arg containsString:@"\\"] || [arg containsString:@"*"]) {
            NSMutableString *thisArg = [[NSMutableString alloc] init];
            for (int j = 0; j < [[NSNumber numberWithUnsignedInteger:[arg length]] intValue]; j++) {
                if ([arg characterAtIndex:j] == ' ' || [arg characterAtIndex:j] == '`'){
                    [thisArg appendString:@"\'"];
                    [thisArg appendFormat:@"%c", [arg characterAtIndex:j]];
                    [thisArg appendString:@"\'"];
                } else if ([arg characterAtIndex:j] == '$') {
                    [thisArg appendString:@"\'"];
                    [thisArg appendFormat:@"%c", [arg characterAtIndex:j]];
                    if ([arg characterAtIndex:(j + 1)] == '{') {
                        j++;
                        [thisArg appendFormat:@"%c", [arg characterAtIndex:j]];
                    }
                    [thisArg appendString:@"\'"];
                } else if ([arg characterAtIndex:j] == '\"' || [arg characterAtIndex:j] == '\'' || [arg characterAtIndex:j] == '\\' || [arg characterAtIndex:j] == '*') {
                    [thisArg appendString:@"\\"];
                    [thisArg appendFormat:@"%c", [arg characterAtIndex:j]];
                } else {
                    [thisArg appendFormat:@"%c", [arg characterAtIndex:j]];
                }
            }
            arg = [NSString stringWithFormat:@"%@", thisArg];
        }
        [args addObject:arg];
    }

    NSString *command = [args componentsJoinedByString:@" "];

    int status = system([command UTF8String]);
    return WEXITSTATUS(status);
}
