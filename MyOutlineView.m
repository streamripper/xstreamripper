#import "MyOutlineView.h"


// RGB values for stripe color (light blue)
#define STRIPE_RED   (230.0 / 255.0)
#define STRIPE_GREEN (240.0 / 255.0)
#define STRIPE_BLUE  (254.0 / 255.0)

// selected but not active, 237,243,255, 192,192,192  ... 109, 158, 208

static NSColor *sStripeColor = nil;

//static NSColor *highlightColor = nil;

@implementation MyOutlineView


//- (void)awakeFromNib {
//    [self setDrawsGrid:YES];
//   highlightColor = [[NSColor colorWithCalibratedRed:109.0/255.0 green:158.0/255.0 blue:208.0/255.0 alpha:1.0] retain];
 //}


// This is called after the table background is filled in, but before the cell contents are drawn.
// We override it so we can do our own light-blue row stripes a la iTunes.
- (void) highlightSelectionInClipRect:(NSRect)rect {
    [self drawStripesInRect:rect];
    [super highlightSelectionInClipRect:rect];
}

// This routine does the actual blue stripe drawing, filling in every other row of the table
// with a blue background so you can follow the rows easier with your eyes.
- (void) drawStripesInRect:(NSRect)clipRect {
    NSRect stripeRect;
    float fullRowHeight = [self rowHeight] + [self intercellSpacing].height;
    float clipBottom = NSMaxY(clipRect);
    int firstStripe = clipRect.origin.y / fullRowHeight;
    if (firstStripe % 2 == 0)
        firstStripe++;			// we're only interested in drawing the stripes
                         // set up first rect
    stripeRect.origin.x = clipRect.origin.x;
    stripeRect.origin.y = firstStripe * fullRowHeight;
    stripeRect.size.width = clipRect.size.width;
    stripeRect.size.height = fullRowHeight;
    // set the color
    if (sStripeColor == nil)
        sStripeColor = [[NSColor colorWithCalibratedRed:STRIPE_RED green:STRIPE_GREEN blue:STRIPE_BLUE alpha:1.0] retain];

//    if ([self isRowSelected:clipRect.origin.y / fullRowHeight]) {
//        [highlightColor set];
//    }
//    else {
    [sStripeColor set];
//    }
        // and draw the stripes
    while (stripeRect.origin.y < clipBottom) {
        NSRectFill(stripeRect);
        stripeRect.origin.y += fullRowHeight * 2.0;
    }
}


@end
