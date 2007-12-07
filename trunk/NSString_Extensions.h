//
//  PlsHelper.h
//  streamripperx
//
//  Created by ruffnex on Sat Oct 26 2002.
//  Copyright (c) 2002 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MyExtensions)

-(NSString *)escapeSpaceInURL;
-(NSString *)getURLWithCurl;
-(NSString *)getValueForKey:(NSString *)key;  // key=value\n

@end
