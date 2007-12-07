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

#import <Foundation/Foundation.h>

// Node.h
//
// This class holds internet radio stream data
// A node holds the data that will be displayed in the outline view.
// A mutable array holds children nodes.

#define NODE_GROUP_LABEL	@"Group"
#define NODE_STREAM_LABEL	@"Stream"
#define NODE_SONG_LABEL		@"Song"

enum NodeType { NODE_GROUP=0, NODE_STREAM, NODE_SONG };

@interface Node : NSObject <NSCoding> {

    NSMutableArray *children;

    NSString *itemName;
    NSString *itemURL;
    BOOL ripping;

    Node *parent;
    enum NodeType nodeType;
}

// Methods
- (BOOL)isDescendantOfNode:(Node*)node;
- (BOOL)isDescendantOfNodeInArray:(NSArray*)nodes;
- (void)insertChild:(Node*)child atIndex:(int)index;
- (void)insertChildren:(NSArray*)kids atIndex:(int)index;
- (int)indexOfChild:(Node*)child;
- (void)removeChild:(Node*)child;

    // Accessor methods
- (int)nodeType;
- (void)setNodeType:(int)t;

- (Node *)parent;
- (void)setParent:(Node *)p;

- (NSString *)itemName;
- (void)setItemName:(NSString *)s;

- (NSString *)itemURL;
- (void)setItemURL:(NSString *)s;


    // Accessor method for setting the state of the node, so we know whether it is ripping or not
    // ...if YES, then we instruct the outlineview to display an icon, etc.
- (BOOL)ripping;
- (void)setRipping:(BOOL)b;


    // Methods for working with the child nodes
- (void)addChild:(Node *)n;
- (void)addChildren:(NSArray *)kids;
- (int)childrenCount;
- (Node *)childAtIndex:(int)i;


    // Is this node expandable? (i.e. are there any children?)
- (BOOL)expandable;


    // Class method
    // Returns the minimum nodes from 'allNodes' required to cover the nodes in 'allNodes'.
    // This methods returns an array containing nodes from 'allNodes' such that no node in
    // the returned array has an ancestor in the returned array.
+ (NSArray *)minimumNodeCoverFromNodesInArray: (NSArray *)allNodes;
@end
