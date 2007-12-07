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

#include "rip_manager.h"
#undef BOOL

#import <Cocoa/Cocoa.h>
#import "RadioStream.h"
#import "Node.h"
#import "OLDataSource.h"
#import "NSOutlineView_Extensions.h"
// above outline_view ext. for hack

#import "MyProxyUtil.h"


//#define ADDRADIOSTREAM(arg1,arg2) [radioStreams addObject:[RadioStream withName:arg1 url:arg2]]

#define DEFAULT_USERAGENT		@"iTunes/7.0 (Macintosh; U; PPC Mac OS X 10.4.7)"
//@"sr-POSIX/1.32"
#define DEFAULT_RELAY_PORT		8000
#define DEFAULT_PROXY_URL		@""

#define DEFAULT_MAKE_RELAY		YES
#define DEFAULT_SEPARATE_DIRS		YES
#define DEFAULT_OVER_WRITE_TRACKS	NO
#define DEFAULT_COUNT_FILES		NO
#define DEFAULT_ADD_ID3			NO
#define DEFAULT_SINGLE_FILE			NO
#define DEFAULT_SEARCH_PORTS		YES
#define DEFAULT_USE_PROXY		NO

// warning: duplicate defn in OLDataSource.m
#define DEFAULTS_RADIO_STREAMS	@"radiostreams"
//#define DEFAULTS_SELECTED_INDEX  @"selectedindex"

#define DEFAULTS_DOWNLOAD_PATH		@"downloadpath"
#define DEFAULTS_USERAGENT	@"useragent"
#define DEFAULTS_RELAY_PORT	@"relayport"
#define DEFAULTS_PROXY_URL	@"proxyurl"

#define DEFAULTS_MAKE_RELAY	@"makerelay"
#define DEFAULTS_SEPARATE_DIRS		@"separatedirs"
#define DEFAULTS_OVER_WRITE_TRACKS	@"overwritetracks"
#define DEFAULTS_COUNT_FILES		@"countfiles"
#define DEFAULTS_ADD_ID3		@"addid3"
#define DEFAULTS_SINGLE_FILE  @"singlefile"
#define DEFAULTS_SEARCH_PORTS		@"searchports"
#define DEFAULTS_USE_PROXY		@"useproxy"

#define DEFAULTS_CFBUNDLEVERSION	@"CFBundleVersion"

@interface AppController : NSObject
{
    IBOutlet id window;
    
    IBOutlet id separateDirs;
    IBOutlet id overWriteTracks;
    IBOutlet id countFiles;
    IBOutlet id addId3;
	IBOutlet id singleFile;
	IBOutlet id filenamePattern;
    IBOutlet id searchPorts;
    IBOutlet id makeRelay;
    IBOutlet id useProxy;
    
    IBOutlet id ripButton;
    IBOutlet id listenButton;

 //   IBOutlet id ripStreamMenuItem;
 //   IBOutlet id stopRippingMenuItem;
    
    IBOutlet id status1;
    IBOutlet id status2;
    IBOutlet id status3;
    IBOutlet id status4;
    IBOutlet id status5;
    IBOutlet id progressIndicator;

//    IBOutlet id popUp;
//    IBOutlet id tableRadioStream;
    
    IBOutlet id downloadPath;
    IBOutlet id userAgent;
    IBOutlet id relayPort;
    IBOutlet id proxyUrl;
    
    IBOutlet id localPortLabel;
    IBOutlet id proxyUrlLabel;
    
    RIP_MANAGER_OPTIONS 	m_opt;
    RIP_MANAGER_INFO		m_curinfo;
    NSPort *callbackPort;
    BOOL ripping;
    BOOL quitting;  // application is in process of quitting

    // radio stations...
//    NSMutableArray *radioStreams;
//    RadioStream *selectedRadioStream;
//    NSMenuItem *selectedMenuItem;

    // AppController knows about the NSOutlineView datasource
    IBOutlet OLDataSource *outlineViewDataSource;

    // Keep a reference to the stream node being ripped, so we can update its attributes
    // Keep a reference to the track node being ripped
    Node *rippingNode,
        *rippingTrackNode;
}

- (IBAction)listen:(id)sender;
- (IBAction)toggleMakeRelay:(id)sender;
- (IBAction)toggleUseProxy:(id)sender;
- (IBAction)rip:(id)sender;
- (IBAction)ripStop:(id)sender;
- (IBAction)selectDownloadPath:(id)sender;
//- (IBAction)newRadioStream:(id)sender;
//- (IBAction)deleteRadioStream:(id)sender;
//- (IBAction)selectRadioStream:(id)sender;
- (IBAction)showGPL:(id)sender;
- (IBAction)showHelp:(id)sender;

- (NSPort *)callbackPort;
- (void)loadUserDefaults;
- (void)saveUserDefaults;
- (void)updateStatus:(BOOL)displayInfo;
- (BOOL)ripStart;
- (void)ripStop;
//- (void)updateTableRadioStreamUI;
//- (void)createNewRadioStream;
//- (void)syncPopUpWithTable;
//- (void)syncRipButtonWithTable;

/*
// Data source methods
- (int)numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)tableView:(NSTableView *)aTableView
 objectValueForTableColumn:(NSTableColumn *)aTableColumn
                       row:(int)rowIndex;
- (void)tableView:(NSTableView *)aTableView
            setObjectValue:(id)anObject
            forTableColumn:(NSTableColumn *)aTableColumn
                       row:(int)rowIndex;
*/

// Reference to instance of AppController
    id myself;

@end
