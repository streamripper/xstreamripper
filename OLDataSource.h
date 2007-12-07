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

#import <Cocoa/Cocoa.h>
#import "Node.h"

//
// I am the data source and delegate of an outlineview
// The AppController class holds a reference to me
//

@interface OLDataSource : NSObject
{
    IBOutlet NSOutlineView *outlineView;
    Node *rootNode; 		// This node is the root of the tree being displayed
    NSArray *draggedNodes;    	// This is for drag and drop of nodes

}

// FIXME: This method only here to allow a hack - to select node (current track) in outlineview
- (NSOutlineView *)outlineView;

// Some useful methods for AppController to invoke
- (void)reloadNode:(Node *)node;
- (Node *)selectedNode;
- (void)loadPrefs;
- (void)savePrefs;

    // convenience method, for adding a child to the rootNode
- (BOOL)addChild:(int)nodeType
            name:(NSString *)name
             URL:(NSString *)URL;

    // This is the method triggered by the button
- (BOOL)addChild:(int)type
          parent:(Node*)parent
            name:(NSString *)name
             URL:(NSString *)URL;

    // Action methods
- (IBAction)addStream:(id)sender;
- (IBAction)addGroup:(id)sender;
- (IBAction)deleteNodes:(id)sender;

- (IBAction)importFromShoutCast:(id)sender; // experimental


    // This is the method invoked when an outline view item is selected
- (IBAction)outlineViewAction:(id)sender;

//helper method
//- (NSString *)getFile1FromPLS:(NSString *)pls;
//- (NSString *)getWithCurl:(NSString *)url;

@end
