/*
 StreamRipperX
 
 Copyright (c) 2002  Wai Hung (Simon) Liu

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

#import "RadioStream.h"


@implementation RadioStream

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ [%@]", streamName, streamUrl];
}

- (NSString *)streamName {
    return streamName;
}

- (void)setStreamName:(NSString *)s {
    [s retain];
    [streamName release];
    streamName = s;
}

- (NSString *)streamUrl {
    return streamUrl;
}

- (void)setStreamUrl:(NSString *)s {
    [s retain];
    [streamUrl release];
    streamUrl = s;
}

- (id)init
{
    if (self = [super init]) {
        [self setStreamName:@"New Radio Stream"];
        [self setStreamUrl:@"Unknown URL" ];
    }
    return self;
}




+ (id)withName:(NSString *)s1 url:(NSString *)s2
{
    RadioStream *r = [[RadioStream alloc] init];
    [r setStreamName:s1];
    [r setStreamUrl:s2];
    return r;
}


- (void)dealloc
{
    [streamName release];
    [streamUrl release];
	[super dealloc];
}


- (void)encodeWithCoder:(NSCoder *)coder
{
    // No need to call [super encodeWithCoder:coder] as superclass is NSObject which does not implement NSCoding
    [coder encodeObject:streamName]; // NSString implements NSCoding protocol so knows how to encode itself
    [coder encodeObject:streamUrl];
}

- (id)initWithCoder:(NSCoder *)coder
{
    if ( self = [super init] ) {
        [self setStreamName:[coder decodeObject]];
        [self setStreamUrl:[coder decodeObject]];
     }
    return self;
}

@end
