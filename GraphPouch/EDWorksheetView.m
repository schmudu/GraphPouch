//
//  EDWorksheetView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDWorksheetView.h"
#import "EDGraphView.h"
#import "Graph.h"

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
    
    //make subviews redraw
    //NSLog(@"redrawing worksheet: array?%@", [self subviews]);
    /*
    if([self subviews])
        NSLog(@"redrawing worksheet: array count: %@", [[self subviews] count]);
    */
    
    for(EDGraphView *graph in [self subviews]){
        //NSLog(@"calling setNeedsDisplay on subview.");
        [graph setNeedsDisplay:TRUE];
        //[graph test];
    }
}

#pragma mark -
#pragma mark Listeners
- (void)handleNewGraphAdded:(NSNotification *)note{
    // draw new graph view
    Graph *myGraph = [note object];
    EDGraphView *graph = [[EDGraphView alloc] initWithFrame:[self bounds] graphModel:myGraph];

    [self addSubview:graph];
    [self setNeedsDisplay:TRUE];
    //NSLog(@"Received notification %@", [myGraph hasGridLines]);
}
@end
