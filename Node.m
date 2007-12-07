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


//
//  Node.m
//

#import "Node.h"


@implementation Node
- (id)init
{
    [super init];
    children = [[NSMutableArray alloc] init];
    itemName = @"";
    itemURL = @"";
    ripping = NO;
    return self;
}

- (void)dealloc
{
    [children release];
    [itemName release];
    [itemURL release];
    [super dealloc];
}


//
// NSCoding protocol
//
- (void)encodeWithCoder:(NSCoder *)coder
{
    // No need to call [super encodeWithCoder:coder] as superclass is NSObject which does not implement NSCoding
    [coder encodeObject:itemName]; // NSString implements NSCoding protocol so knows how to encode itself
    [coder encodeObject:itemURL];
    [coder encodeObject:children]; // NSMutableArray implements NSCoding
    [coder encodeObject:parent];   // Node implements NSCoding
    [coder encodeValueOfObjCType:@encode(int) at:&nodeType];
}

- (id)initWithCoder:(NSCoder *)coder
{
    if ( self = [super init] ) { //;WithCoder:coder]
        [self setItemName:[coder decodeObject]];
        [self setItemURL:[coder decodeObject]];
        [children release];
        children = [coder decodeObject];
        [children retain];
        // TODO: Create a setChildren method?
        [self setParent:[coder decodeObject]];
        [coder decodeValueOfObjCType:@encode(int) at:&nodeType];
    }
    return self;
}



//
// Accessor methods for the type
//
- (int)nodeType {
    return nodeType;
}

- (void)setNodeType:(int)t {
    nodeType = t;
}


//
// Accessor methods for the Name
//
- (void)setItemName:(NSString *)s
{
    [s retain];
    [itemName release];
    itemName = s;
}

- (NSString *)itemName
{
    return itemName;
}



//
// Accessor methods for the URL
//
- (void)setItemURL:(NSString *)s
{
    [s retain];
    [itemURL release];
    itemURL = s;
}

- (NSString *)itemURL
{
    return itemURL;
}


//
// Accessor methods for the Ripping state
//
- (BOOL)ripping { return ripping; }
- (void)setRipping:(BOOL)b {
    ripping = b;
}


//
// Accessor methods for the Parent node data
//
- (Node *)parent
{
    return parent;
}

- (void)setParent:(Node *)p
{
    [p retain];
    [parent release];
    parent = p;
}



//
// Child/Parent related methods
//
- (void)removeFromParent {
    [[self parent] removeChild:self];
}



- (void)addChild:(Node *)n
{
    [n setParent:self];
    [children addObject:n];
}


// lazy...
- (void)addChildren:(NSArray*)kids {
    [self insertChildren:kids atIndex:[children count]];
}



- (Node *)childAtIndex:(int)i
{
    return [children objectAtIndex:i];
}


- (int)childrenCount
{
    return [children count];
}


- (BOOL)expandable
{
    return ([children count] > 0);
}


- (int)indexOfChild:(Node*)child {
    return [children indexOfObjectIdenticalTo:child];
}


- (void)removeChild:(Node*)child {
    int index = [self indexOfChild: child];
    if (index!=NSNotFound) {
        [child setParent:nil];
        [children removeObjectAtIndex:index]; // removeObjectIdenticalTo:... removes all occurrences
    }
}




//
// Insert child(ren)
//
- (void)insertChild:(Node*)child atIndex:(int)index {
    [child setParent: self];
    [children insertObject:child atIndex:index];
}

- (void)insertChildren:(NSArray*)kids atIndex:(int)index {
    NSEnumerator *kidsEnum;
    Node *child;
    [kids makeObjectsPerformSelector:@selector(setParent:) withObject:self]; // dynamic runtime!
//    [children insertObjectsFromArray: kids atIndex: index];  // extension
    kidsEnum = [kids objectEnumerator ];
    while (child = [kidsEnum nextObject]) {
        [children insertObject:child atIndex:index++ ];        
    }
}





//
// Work out if node is the descendant of another node...
//
- (BOOL)isDescendantOfNode:(Node*)node {
    // returns YES if 'node' is an ancestor.
    // Walk up the tree, to see if any of our ancestors is 'node'.
    Node *n = self;
    while(n) {
        if(n==node) return YES;
        n = [n parent];
    }
    return NO;
}

- (BOOL)isDescendantOfNodeInArray:(NSArray*)nodes {
    // returns YES if any 'node' in the array 'nodes' is an ancestor of ours.
    // For each node in nodes, if node is an ancestor return YES.  If none is an
    // ancestor, return NO.
    NSEnumerator *nodeEnum = [nodes objectEnumerator];
    Node *n = nil;
    while((n=[nodeEnum nextObject])) {
        if([self isDescendantOfNode:n]) return YES;
    }
    return NO;
}







//
// from apple example
//
// Returns the minimum nodes from 'allNodes' required to cover the nodes in 'allNodes'.
// This methods returns an array containing nodes from 'allNodes' such that no node in
// the returned array has an ancestor in the returned array.
    // There are better ways to compute this, but this implementation should be efficient for our app.
+ (NSArray *) minimumNodeCoverFromNodesInArray: (NSArray *)allNodes {
    NSMutableArray *minimumCover = [NSMutableArray array];
    NSMutableArray *nodeQueue = [NSMutableArray arrayWithArray:allNodes];
    Node *node = nil;
    while ([nodeQueue count]) {
        node = [nodeQueue objectAtIndex:0];
        [nodeQueue removeObjectAtIndex:0];
        while ( [node parent] && ( [nodeQueue indexOfObjectIdenticalTo:[node parent]] != NSNotFound)) {
            [nodeQueue removeObjectIdenticalTo: node];
            node = [node parent];
        }
        if (![node isDescendantOfNodeInArray: minimumCover]) [minimumCover addObject: node];
        [nodeQueue removeObjectIdenticalTo: node];
    }
    return minimumCover;
}


@end
