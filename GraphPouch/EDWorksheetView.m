//
//  EDWorksheetView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDWorksheetView.h"
#import "EDConstants.h"

@implementation EDWorksheetView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // listen
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(handleNewGraphAdded:) name:EDNotificationGraphAdded object:nil];
    }
    
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect bounds = [self bounds];
    [[NSColor whiteColor] set];
    [NSBezierPath fillRect:bounds];
}

#pragma mark -
#pragma mark Listeners
- (void)handleNewGraphAdded:(NSNotification *)note{
    // draw new graph view
    
    NSLog(@"Received notification %@", note);
}
@end
