//
//  MyProxyUtil.m
//  LibCurlCocoaTest
//
//  Created by ruffnex on Sun Feb 09 2003.
//  Copyright (c) 2003 __MyCompanyName__. All rights reserved.
//


#import "MyProxyUtil.h"


@implementation MyProxyUtil

			
#define NSS(s) (NSString *)(s)

+(NSString *)getSCFProxyHTTP
{
			SCDynamicStoreRef sSCDSRef = NULL;
        	sSCDSRef = SCDynamicStoreCreate(NULL,(CFStringRef) @"srx",NULL, NULL);
        	if ( sSCDSRef != NULL ) {
          		NSDictionary *proxies = (NSDictionary *) SCDynamicStoreCopyProxies(sSCDSRef);
                if ((proxies) && [[proxies objectForKey:NSS(kSCPropNetProxiesHTTPEnable)] boolValue] )
                {
					NSString *proxyHost = (NSString *) [proxies objectForKey:NSS(kSCPropNetProxiesHTTPProxy)];
                    NSNumber *proxyPort = (NSNumber *)[proxies objectForKey:NSS(kSCPropNetProxiesHTTPPort)];
                    return [NSString stringWithFormat:@"%@:%@", proxyHost, proxyPort];
                    //NSLog(@"Proxies = %@ [%@:%@]", [proxies description], proxyHost, proxyPort);
				}
            }
           		return nil;

}
@end
