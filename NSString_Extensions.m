//
//  PlsHelper.m
//  streamripperx
//
//  Created by ruffnex on Sat Oct 26 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import "NSString_Extensions.h"
#import <Foundation/NSTask.h>

@implementation NSString (MyExtensions)

/*
 * Get data at URL with Curl
 * Create a NSTask to invoke "curl -sL "http://..."
 * -L flag tells curl to follow HTTP 302 redirection
 * -s silent
 * Return output as string
 * TODO: Set parameter for encoding
 */
- (NSString *)getURLWithCurl
{
    NSTask *task;
    NSFileHandle *fromCurl;
    NSPipe *fromPipe;
    NSString *result;
    
#ifdef DEBUG
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"url = %@", self);
#endif

    fromPipe = [NSPipe pipe];
    fromCurl = [fromPipe fileHandleForReading];

    task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/curl"];
    // [task setLaunchPath:[[NSBundle mainBundle] pathForResource:@"curl7103" ofType:nil]];
    [task setArguments:
    //   [NSArray arrayWithObjects:@"-sL",self, nil]];
        [NSArray arrayWithObjects:@"--connect-timeout",@"10",
				 @"--max-filesize",@"4096",
				 @"-m",@"11",
				 @"--no-buffer",
				 @"-A",@"iTunes/4.2 (Macintosh; U; PPC Mac OS X 10.2)",
            //@"--max-redirs",@"10",
            @"-sL",self, nil]];

    //[task setStandardInput:nil];
    [task setStandardOutput:fromPipe];
    [task launch];

#ifdef DEBUG
	NSLog(@"environment = %@\n", [task environment]);
#endif

    result = [[NSString alloc] initWithData:[fromCurl readDataToEndOfFile]
                                   encoding:NSASCIIStringEncoding];
#ifdef DEBUG
    NSLog(@"output from curl = \n%@", result);
#endif

    [fromCurl closeFile];
    [task release];
    return result; // nil = nothing, error connecting
}


/*
 * Parse parameter for key File1=<value>\n from a string (representing a textfile with \n separator)
 * PLaylist .pls file format (typical)
 *    [playlist]\n
 *    File1=http://...8080\n
 * Return a string (which should hold URL of mp3 stream)
 */
-(NSString *)getValueForKey: (NSString *)key {
    int tmp;
    NSRange range;
#ifdef DEBUG
    NSLog(@"%s", __PRETTY_FUNCTION__);
    NSLog(@"data = %@", self);
#endif
    range = [self rangeOfString:[key stringByAppendingString:@"="]         //@"File1=http"
                       options:NSCaseInsensitiveSearch ];
//   if ( [ self hasPrefix:@"[playlist]"] &&

    if ( range.location != NSNotFound )
    {
        tmp = range.location+([key length]+1);
        range = [[self substringFromIndex:tmp] rangeOfString:@"\n"];
        if (range.location != NSNotFound) {
            range.length = range.location;
            range.location = tmp;
            return [self substringWithRange:range];
        }
    }
    return nil;
}


/*
 Given a string, convert ' ' into "%20"
 */
-(NSString *)escapeSpaceInURL {
    return [ [self componentsSeparatedByString:@" "] componentsJoinedByString:@"%20" ];
}

@end
