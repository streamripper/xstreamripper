//
//  NSOutlineView_Extensions.h
//
//  Copyright (c) 2001 Apple. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSOutlineView (MyExtensions)

- (id)selectedItem;
- (NSArray*)allSelectedItems;
- (void)selectItems:(NSArray*)items byExtendingSelection:(BOOL)extend;

@end

/*
@interface MyOutlineView : NSOutlineView {
}
@end
*/