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

#import "AppController.h"


/*
 * Callback runs in another thread, not in NSRunLoop
 */
void streamripper_callback(int messageId, void *messageData)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    // Wrap up the data in NSData object and send in components array
    NSData *data;
    NSArray *array;
    NSPortMessage *message;

    switch (messageId) {
        case RM_UPDATE:
            data = [NSData dataWithBytes:messageData length:sizeof(RIP_MANAGER_INFO)];
            break;
        case RM_ERROR:
            data = [NSData dataWithBytes:messageData length:sizeof(ERROR_INFO)];
            break;
        default:
            data = [NSData data];
    }
    array = [NSArray arrayWithObject:data];
    message = [[NSPortMessage alloc] initWithSendPort:[myself callbackPort]
                                          receivePort:[myself callbackPort]
                                           components:array];
    [message setMsgid:messageId];
    [message sendBeforeDate:nil];
    [message release];
    [pool release];
}






@implementation AppController

- (id)init
{


    if (self = [super init]) {
        //        radioStreams = [[NSMutableArray alloc] init];
        // Setup NSTask
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(checkATaskStatus:)
                                                     name:NSTaskDidTerminateNotification
                                                   object:nil];
        // Setup callback
        callbackPort = [[NSPort port] retain];
        [callbackPort setDelegate:self];
        [[NSRunLoop currentRunLoop] addPort:callbackPort forMode:NSDefaultRunLoopMode];

        myself = self;
        ripping = FALSE;
    }
    return self;
}


- (void) dealloc
{
    [callbackPort release];
    //    [radioStreams release];
	[super dealloc];
}

/*
- (void)resetCursorRects
{
    id aCursor = [[NSCursor currentCursor] initWithImage:[NSImage imageNamed:@"LinkCursor.tiff"] hotSpot: NSMakePoint(0,0)];
    [ripButton addCursorRect:[ripButton visibleRect] cursor:aCursor];
    [aCursor setOnMouseEntered:YES];
    NSLog(@"resetCursorRects:");
}
*/

- (void)awakeFromNib
{
    
#ifdef DEBUG
    //NSBundle *bundleID;

    NSLog(@"%s", __PRETTY_FUNCTION__);
    // set flag for target... but that would mean DEBUG is set while on top customer
    NSLog(@"debug switch on = DEBUG");

    //bundleID = [[NSBundle mainBundle] bundleIdentifier];
    //NSLog(@"mainBundle identifier = %@", bundleID);
    //NSLog(@"%@", [[NSBundle mainBundle] pathForResource:@"gpl" ofType:@"txt"] );
#endif

    //NSLog(@"bundle dictionary=%@", [[NSBundle mainBundle] infoDictionary]);

    //

    [window setFrameUsingName:[window title]];
    [progressIndicator setMaxValue:1024*1024];

    [self loadUserDefaults];
}


/*
 * Load user defaults
 * - register defaults if none
 * - Setup GUI based on user defaults
 * note: ??? use DEFAULTS_CFBUNDLEVERSION to store version number of previous prefs file
 */
- (void)loadUserDefaults {

    NSMutableDictionary *factorySettings = [NSMutableDictionary dictionary];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    id oldRadioStreams = nil;

    // 1 nov02 - can remove this code, unlikely anyone is using beta release!
    // Migrate old RadioStream data from 1.0beta (first release)
    if ([defaults objectForKey:DEFAULTS_RADIO_STREAMS]) {
        oldRadioStreams = [NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:DEFAULTS_RADIO_STREAMS]];

        if ([oldRadioStreams isKindOfClass:[NSMutableArray class]]) {
#ifdef DEBUG
            NSLog(@"Migrating old 1.0beta stream data from \"RadioStream\" class to \"Node\" data ");
#endif
            [defaults removeObjectForKey:DEFAULTS_RADIO_STREAMS];
            [defaults synchronize];
        }
        else {
            oldRadioStreams = nil;
        }
    }


    // Default factory settings

    [factorySettings setObject:[NSString stringWithFormat:@"%s/Music/", getenv("HOME")]
                        forKey:DEFAULTS_DOWNLOAD_PATH];
    [factorySettings setObject:DEFAULT_USERAGENT forKey:DEFAULTS_USERAGENT];
    [factorySettings setObject:DEFAULT_PROXY_URL forKey:DEFAULTS_PROXY_URL];

    [factorySettings setObject:[NSNumber numberWithInt:DEFAULT_RELAY_PORT] forKey:DEFAULTS_RELAY_PORT];
    [factorySettings setObject:[NSNumber numberWithBool:DEFAULT_MAKE_RELAY] forKey:DEFAULTS_MAKE_RELAY];
    [factorySettings setObject:[NSNumber numberWithBool:DEFAULT_SEPARATE_DIRS] forKey:DEFAULTS_SEPARATE_DIRS];
    [factorySettings setObject:[NSNumber numberWithBool:DEFAULT_OVER_WRITE_TRACKS] forKey:DEFAULTS_OVER_WRITE_TRACKS];
    [factorySettings setObject:[NSNumber numberWithBool:DEFAULT_COUNT_FILES] forKey:DEFAULTS_COUNT_FILES];
	[factorySettings setObject:[NSNumber numberWithBool:DEFAULT_ADD_ID3] forKey:DEFAULTS_ADD_ID3];
	[factorySettings setObject:[NSNumber numberWithBool:DEFAULT_SINGLE_FILE] forKey:DEFAULTS_SINGLE_FILE];
    [factorySettings setObject:[NSNumber numberWithBool:DEFAULT_SEARCH_PORTS] forKey:DEFAULTS_SEARCH_PORTS];
    [factorySettings setObject:[NSNumber numberWithBool:DEFAULT_USE_PROXY] forKey:DEFAULTS_USE_PROXY];

    [defaults registerDefaults: factorySettings];
    [defaults synchronize];


    // Set up GUI

    // TODO: Make a macro, e.g. getBoolDefault(name), getIntDefault(name), etc.
	[addId3 setState:[[defaults objectForKey:DEFAULTS_ADD_ID3] boolValue] ];
	[singleFile setState:[[defaults objectForKey:DEFAULTS_SINGLE_FILE] boolValue] ];
    [countFiles setState:[[defaults objectForKey:DEFAULTS_COUNT_FILES] boolValue] ];
    [overWriteTracks setState:[[defaults objectForKey:DEFAULTS_OVER_WRITE_TRACKS] boolValue] ];
    [searchPorts setState:[[defaults objectForKey:DEFAULTS_SEARCH_PORTS] boolValue] ];
    [separateDirs setState:[[defaults objectForKey:DEFAULTS_SEPARATE_DIRS] boolValue] ];
    [makeRelay setState:[[defaults objectForKey:DEFAULTS_MAKE_RELAY] boolValue] ];
    [relayPort setIntValue:[[defaults objectForKey:DEFAULTS_RELAY_PORT] intValue] ];
    [userAgent setStringValue:[defaults objectForKey:DEFAULTS_USERAGENT]];
    [downloadPath setStringValue:[defaults objectForKey:DEFAULTS_DOWNLOAD_PATH]];
    [useProxy setState:[[defaults objectForKey:DEFAULTS_USE_PROXY] boolValue] ];
    [proxyUrl setStringValue:[defaults objectForKey:DEFAULTS_PROXY_URL]];

    // set up button state depending on pref

    [self toggleMakeRelay:makeRelay];


    // Set up Radio (node) data
    [outlineViewDataSource loadPrefs];


    // Migrate old data from 1.0beta (if necessary)
    if (oldRadioStreams) {
        NSEnumerator *enumerator = [oldRadioStreams objectEnumerator];
        id obj;

        while ((obj = [enumerator nextObject])) {
            [outlineViewDataSource addChild:NODE_STREAM
                                       name:[obj streamName]
                                        URL:[obj streamUrl]];
        }
    }

    
}





- (void)saveUserDefaults {
    NSUserDefaults *defaults;
    //    NSString *bundleID;

    defaults = [NSUserDefaults standardUserDefaults];
    //    bundleID= [[NSBundle mainBundle] bundleIdentifier];

    // save window frame position
    [window saveFrameUsingName:[window title]];

    // Save current settings
    [defaults setObject:[downloadPath stringValue]
                 forKey:DEFAULTS_DOWNLOAD_PATH];
    [defaults setObject:[userAgent stringValue]
                 forKey:DEFAULTS_USERAGENT];
    [defaults setObject:[proxyUrl stringValue]
                 forKey:DEFAULTS_PROXY_URL];
    [defaults setObject:[NSNumber numberWithInt:[relayPort intValue]]
                 forKey:DEFAULTS_RELAY_PORT];
    [defaults setObject:[NSNumber numberWithBool:[makeRelay state]]
                 forKey:DEFAULTS_MAKE_RELAY];
    [defaults setObject:[NSNumber numberWithBool:[separateDirs state]]
                 forKey:DEFAULTS_SEPARATE_DIRS];
    [defaults setObject:[NSNumber numberWithBool:[overWriteTracks state]]
                 forKey:DEFAULTS_OVER_WRITE_TRACKS];
    [defaults setObject:[NSNumber numberWithBool:[countFiles state]]
                 forKey:DEFAULTS_COUNT_FILES];
	[defaults setObject:[NSNumber numberWithBool:[addId3 state]]
							 forKey:DEFAULTS_ADD_ID3];
	[defaults setObject:[NSNumber numberWithBool:[singleFile state]]
							 forKey:DEFAULTS_SINGLE_FILE];
    [defaults setObject:[NSNumber numberWithBool:[searchPorts state]]
                 forKey:DEFAULTS_SEARCH_PORTS];
    [defaults setObject:[NSNumber numberWithBool:[useProxy state]]
                 forKey:DEFAULTS_USE_PROXY];
    /*
        [defaults setObject:[NSArchiver archivedDataWithRootObject:radioStreams]
                     forKey:DEFAULTS_RADIO_STREAMS];
     */
    [defaults synchronize];

    // Save outline view data
    [outlineViewDataSource savePrefs];

}




/*
* This method is a delegate of File's Owner... which in our case is NSApp
* Invoked when the user invokes menuitem File->Quit
*/
 - (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
 {
     if (!ripping) return YES;
     return [self windowShouldClose:sender];
 }
 


/*
 * When application quits, it will instruct all windows to close...
 * If so, we make sure we stop ripping (which will then clean up)
 */
- (void)windowWillClose:(NSNotification *)aNotification
{
    if (ripping) rip_manager_stop();
    [self saveUserDefaults];
}


/*
 * We are going to close window - should we allow it?
 */
- (BOOL)windowShouldClose:(id)sender
{
	if (quitting) return YES;

    if (!ripping) {
		quitting = YES;
        [NSApp terminate:self];  // close window... also close app
        return YES;
    }

    NSBeginAlertSheet(NSLocalizedString(@"Quit",nil),
                      NSLocalizedString(@"OK",nil),
                      NSLocalizedString(@"Cancel",nil),
                      nil, window, self, nil,
                      @selector(endQuitAlertSheet:returnCode:contextInfo:),
                      nil,
                      NSLocalizedString(@"SureQuit",nil) );
    return NO;
    // default action is not to quit, but callback will terminate app if that's what the user wants
}

- (void)endQuitAlertSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
    if (returnCode == NSAlertDefaultReturn) {
    	quitting = YES;
    	[NSApp terminate:self];
    	}
    //NSAlertAlternateReturn
}


/**
* End Alert Sheet - for when we don't care about the result of the sheet (usually info on display)
*/
- (void)endAlertSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
}



/*
 * Return our callback port
 */
- (NSPort *)callbackPort
{
    return callbackPort;
}



/*
 * Create a NSTask to invoke "osascript" and launch iTunes to listen to local relay port
 */
- (IBAction)listen:(id)sender
{
	NSAppleScript *apple = [[NSAppleScript alloc] initWithSource:
		[NSString stringWithFormat:
		@"tell application \"iTunes\" \n open location \"localhost:%d\" \n end tell",
		[relayPort intValue]]];
 if (apple) {
 	[apple executeAndReturnError:nil];
 	}
 	
/*
    NSTask *task;
    NSFileHandle *fh;
    NSPipe *pipe;
    const char *input;

    pipe = [NSPipe pipe];
    fh = [pipe fileHandleForWriting];

    task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/bin/osascript"];
    [task setStandardInput:pipe];
    [task launch];

    input = [[NSString stringWithFormat:
@"tell application \"iTunes\" \n open location \"localhost:%d\" \n end tell", [relayPort intValue]] cString];
    [fh writeData:[NSData dataWithBytes:input length:strlen(input)]];
    [fh closeFile];

    [task release];
    */
}


- (void)checkATaskStatus:(NSNotification *)aNotification {
    // We don't really care about the result... but we might do in the future, esp.
    // if we launch other audio players e.g. Audion
    /*
     int status = [[aNotification object] terminationStatus];
     if (status == 0)
     NSLog(@"Task succeeded.");
     else
     NSLog(@"Task failed.");
     */
}




// Delegate method for NSPort delegate
- (void)handlePortMessage:(NSPortMessage *)portMessage
{
    BOOL static newTrack = NO;
    ERROR_INFO *err;
    NSData *data = [[portMessage components] objectAtIndex:0];

    switch( [ portMessage msgid] )
    {
        case RM_UPDATE:
#ifdef DEBUG        
        NSLog(@"RM_UPDATE");
#endif
            memcpy(&m_curinfo, [data bytes], sizeof(RIP_MANAGER_INFO));
            [self updateStatus:newTrack];
            if (newTrack) {
                int c = [rippingNode childrenCount];
                NSString *trackName = [NSString stringWithCString:m_curinfo.filename];
                BOOL skip = NO;
                Node *n = nil;
#ifdef DEBUG
                NSLog(@"new track = %s", m_curinfo.filename );
#endif
                // Search children of rippingNode parent for a node of the same name
                // If it exists, we are probably ripping the same song twice...
                // so why create another node entry?
                while (--c >= 0) {
                    n = [rippingNode childAtIndex:c];

#ifdef DEBUG
                    NSLog(@"child name = %@", [n itemName] );
#endif
                    
                    if ([[n itemName] isEqualToString:trackName]) {
#ifdef DEBUG
                        NSLog(@"match!" );
#endif
                        skip=YES;
                        break;
                    }
                }

                if (rippingTrackNode) [rippingTrackNode setRipping:NO];

                if (!skip) {
                    [outlineViewDataSource addChild:NODE_SONG
                                             parent:rippingNode
                                               name:trackName
                                                URL:@""];
                    // adds child to last index position
                    rippingTrackNode = [rippingNode childAtIndex:([rippingNode childrenCount] - 1)];
                } else {
                    rippingTrackNode = n;
#ifdef DEBUG
                    NSLog(@"about to select old node" );
#endif                    
                    [[outlineViewDataSource outlineView]
selectItems:[NSArray arrayWithObjects:n,nil]
byExtendingSelection:NO];
       //             [outlineViewDataSource reloadNode:n];
                    //[outlineViewDataSource select
                }

                [rippingTrackNode setRipping:YES];
                [rippingTrackNode retain]; // if node is deleted, we're in trouble, so retain/release
                newTrack = NO;
                [[outlineViewDataSource outlineView] reloadData];

            }
                break;
        case RM_ERROR:
#ifdef DEBUG        
        NSLog(@"RM_ERROR");
#endif
            err = (ERROR_INFO*)[data bytes];
            [self ripStop];
            newTrack = NO;
            
                NSBeginAlertSheet([NSString stringWithFormat:NSLocalizedString(@"ErrorCode",nil)
                                , err->error_code],
                      NSLocalizedString(@"OK",nil),
                      nil,
                      nil, window, self, nil,
                      @selector(endAlertSheet:returnCode:contextInfo:),
                      nil,[NSString stringWithFormat:@"%s", err->error_str]
                       );
            
            break;
        case RM_DONE:
#ifdef DEBUG        
        NSLog(@"RM_DONE");
#endif
            [self ripStop];
            newTrack = NO;
            break;
        case RM_NEW_TRACK:
#ifdef DEBUG        
        NSLog(@"RM_NEW_TRACK");
#endif
            newTrack = YES;
            break;
        case RM_STARTED:
#ifdef DEBUG        
        NSLog(@"RM_STARTED");
#endif
            // Set the name of the radiostream from metadata
            [rippingNode setItemName:[NSString stringWithCString:m_curinfo.streamname]];
            [outlineViewDataSource reloadNode:rippingNode]; // refresh
            break;
    }
}


// Display basic info about radio station and song
- (void)updateStatus:(BOOL)displayInfo
{
    BOOL static animating = NO;
    BOOL static statusRipping = NO;

    if (displayInfo) {
        [status1 setStringValue:[NSString stringWithCString:m_curinfo.streamname]];
        [status2 setStringValue:[NSString stringWithCString:m_curinfo.filename]];
        [status3 setStringValue:[NSString stringWithCString:m_curinfo.server_name]];
        [status4 setStringValue:[NSString stringWithFormat:@"%d kbit/s", m_curinfo.bitrate]];
    }

    switch(m_curinfo.status)
    {
        case RM_STATUS_BUFFERING:
            if (!animating) {
                [progressIndicator setIndeterminate:YES];
                [progressIndicator startAnimation:self];
                animating = YES;
            }
            [status5 setStringValue:NSLocalizedString(@"Buffering",nil)];
            statusRipping = NO;
            break;

        case RM_STATUS_RIPPING:
            if (animating) {
                [progressIndicator setIndeterminate:NO];
                [progressIndicator stopAnimation:self];
                animating = NO;
            }

            // NOTE: Set an NSTimer for smoother progress bar.. but not essential
            if (!statusRipping) {
                [status5 setStringValue:NSLocalizedString(@"Ripping",nil)];
                statusRipping = YES;
            }
            
            /* display status */
            if (m_curinfo.filesize > 0)
            {
                unsigned long size = m_curinfo.filesize;
                int seconds = size / ( (1024/8) * m_curinfo.bitrate);
                NSString *status, *time;

                [progressIndicator setDoubleValue: (double) (size % (1024*1024))  ];

                if (size > 1024*1024) {
                    status = [NSString stringWithFormat:@"%#.3g mb", (double) size/(1024*1024)];
                }
                else {
                    status = [NSString stringWithFormat:@"%d kb", (size / 1024)];
                }

                time = [NSString stringWithFormat:@" / %d:%02d mins", seconds / 60, seconds % 60];

                [rippingTrackNode setItemURL:[status stringByAppendingString:time]];
                [outlineViewDataSource reloadNode:rippingTrackNode]; // refresh
            }

                
            break;
        case RM_STATUS_RECONNECTING:
            [status5 setStringValue:NSLocalizedString(@"Reconnecting",nil)];
            statusRipping = NO;
            break;
    }
}




/*
 State 1 : Not ripping
 State 2 : Ripping
 FIXME: hardcoded image names
 */
- (IBAction)rip:(id)sender
{
    if (!ripping) {

        rippingNode = [[outlineViewDataSource selectedNode] retain];
        // TODO: Assert... check that rippingNode != nil
        if (!rippingNode ||
            [rippingNode nodeType]!=NODE_STREAM) return;

        if ([self ripStart]) {
            ripping = YES;
            [rippingNode setRipping:YES];
            [ripButton setImage:[NSImage imageNamed:@"stock_stop"]];
            [listenButton setEnabled:YES];
        } else {
            [rippingNode release];
        }
    } else {
#ifdef DEBUG        
        NSLog(@"about to invoke rip_manager_stop()");
#endif
        rip_manager_stop();
#ifdef DEBUG        
        NSLog(@"about to invoke ripStop()");
#endif
    }
}


- (IBAction)ripStop:(id)sender {
    [self rip:sender];
}


- (void)ripStop {
#ifdef DEBUG        
        NSLog(@"%s", __PRETTY_FUNCTION__);
        NSLog(@"ripping = %d", ripping);
#endif
    if (ripping) {

        ripping = NO;
        [ripButton setImage:[NSImage imageNamed:@"stock_exec"]];

        [progressIndicator setIndeterminate:NO];
        [progressIndicator setDoubleValue:0.0];

        [listenButton setEnabled:NO];

        [status1 setStringValue:@""];
        [status2 setStringValue:@""];
        [status3 setStringValue:@""];
        [status4 setStringValue:@""];
        [status5 setStringValue:@""];

        [rippingNode setRipping:NO];
        [rippingNode release];

        [rippingTrackNode setRipping:NO];
        [rippingTrackNode release];
        rippingTrackNode = nil;
        [[outlineViewDataSource outlineView] reloadData];

    }
}


- (BOOL)ripStart {
	// Defaults
	set_rip_manager_options_defaults (&m_opt);
	m_opt.relay_port = [relayPort intValue];
	m_opt.max_port = 18000;
	m_opt.proxyurl[0] = (char)NULL;

    // Proxy (if enabled)
    if ([ useProxy state]) {
        strncpy(m_opt.proxyurl, [[proxyUrl stringValue] UTF8String], MAX_URL_LEN);
	}
	/*
	else {
		NSString *webProxy = [MyProxyUtil getSCFProxyHTTP];
		if (webProxy) {
		        strncpy(m_opt.proxyurl, [webProxy cString], MAX_URL_LEN);
		}
	}
	*/

    m_opt.flags |= OPT_AUTO_RECONNECT;
    if ([ separateDirs state ])
        m_opt.flags ^= OPT_SEPERATE_DIRS;
    if ([ searchPorts state])
        m_opt.flags ^= OPT_SEARCH_PORTS;
	if ([ addId3 state ])
		m_opt.flags ^= OPT_ADD_ID3V2;
  	m_opt.flags ^= OPT_ADD_ID3V1;
	if ([ singleFile state ])
		m_opt.flags ^= OPT_SINGLE_FILE_OUTPUT;
    if ([ makeRelay state])
        m_opt.flags ^= OPT_MAKE_RELAY;
    if ([ countFiles state])
        m_opt.flags ^= OPT_COUNT_FILES;
    if ([ overWriteTracks state])
        m_opt.flags ^= OPT_KEEP_INCOMPLETE;

	strcpy(m_opt.output_directory, [[[downloadPath stringValue] stringByStandardizingPath] cStringUsingEncoding:NSASCIIStringEncoding] );
#ifdef DEBUG
	NSLog(@"output directory : %s\n", m_opt.output_directory);
    NSLog(@"url to resolve / rip: %@", [rippingNode itemURL]);
#endif
    // If .pls, or .pls?... then we need to parse the .pls file for the radio stream IP address
    {
			NSString *url = [rippingNode itemURL];
			if ( ! [[url lowercaseString] hasPrefix:@"http://"] )
				url = [@"http://" stringByAppendingString:url];
			if (url) {
					strncpy(m_opt.url, [url cStringUsingEncoding:NSASCIIStringEncoding], MAX_URL_LEN);
        }
        else {
            // url = nil, so we failed...
            NSBeginAlertSheet([NSString stringWithFormat:NSLocalizedString(@"ErrorCode",nil)
                , 888],
                              NSLocalizedString(@"OK",nil),
                              nil,
                              nil, window, self, nil,
                              @selector(endAlertSheet:returnCode:contextInfo:),
                              nil,@"If the station plays in iTunes, StreamRipperX is having problems resolving the URL.  This occurs occasionally with one or two of the iTunes streams.  Otherwise the station may be busy."
                              );
            return NO;
        }
    }
#ifdef DEBUG
    NSLog(@"ripStart: %s", m_opt.url );
#endif
    strcpy(m_opt.useragent, [[userAgent stringValue] UTF8String] );

    return ( rip_manager_start( streamripper_callback, &m_opt) == SR_SUCCESS );
}


// ACTION
- (void)toggleMakeRelay:(id)sender {
    BOOL b = [sender state];
    [localPortLabel setEnabled:b];
    [relayPort setEnabled:b];
    [searchPorts setEnabled:b];
    [listenButton setEnabled:b];
}

- (void)toggleUseProxy:(id)sender {
    BOOL b = [sender state];
    [proxyUrlLabel setEnabled:b];
    [proxyUrl setEnabled:b];
}



// FIXME: Use NSSavePanel instead????
- (IBAction)selectDownloadPath:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
    [panel beginSheetForDirectory:[downloadPath stringValue]
                             file:nil
                            types:nil
                   modalForWindow:[NSApp mainWindow]
                    modalDelegate:self
                   didEndSelector:@selector(selectDownloadPathPanelDidEnd:returnCode:contextInfo:)
                      contextInfo:nil];
}

-(void)selectDownloadPathPanelDidEnd:(NSOpenPanel *)openPanel
                                 returnCode:(int)returnCode
                                contextInfo:(void *)x
{
    if (returnCode == NSOKButton) {
        [downloadPath setStringValue:[openPanel filename]];
    }
}

- (IBAction)showGPL:(id)sender {
[NSTask launchedTaskWithLaunchPath:@"/usr/bin/open"
                         arguments:[NSArray arrayWithObjects:
                             [[NSBundle mainBundle] pathForResource:@"gpl" ofType:@"txt"],
                             nil]];
}

- (IBAction)showHelp:(id)sender {
    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/open"
                             arguments:[NSArray arrayWithObjects:
                                 [[NSBundle mainBundle] pathForResource:@"UsingXStreamRipper" ofType:@"rtf"],
                                 nil]];
}

/* Validate menu items, where target is this class, based on state */
- (BOOL)validateMenuItem:(NSMenuItem *)anItem {
    if ([[anItem title] isEqualToString:@"Rip Stream"])
        return !ripping;
    if ([[anItem title] isEqualToString:@"Stop Ripping"])
        return ripping;
    return YES;
}

@end
