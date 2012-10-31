//
//  EDGraphView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/22/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility.h"
#import "EDGraphView.h"
#import "EDElement.h"
#import "NSManagedObject+Attributes.h"
#import "NSObject+Document.h"
#import "EDGraph.h"
#import "EDConstants.h"

@interface EDGraphView()

@end

@implementation EDGraphView
//@synthesize graph;

- (BOOL)isFlipped{
    return TRUE;
}

- (id)initWithFrame:(NSRect)frame graphModel:(EDGraph *)myGraph{
    self = [super initWithFrame:frame];
    if (self){
        //generate id
        [self setViewID:[EDGraphView generateID]];
        
        // set model info
        [self setDataObj:myGraph];
    }
    return self;
}

- (void) dealloc{
    NSManagedObjectContext *context = [self currentContext];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_nc removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:context];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // set background
    if ([[self dataObj] isSelectedElement]){
        [[NSColor redColor] set];
    }
    else {
        [[NSColor greenColor] set];
    }
    
    [NSBezierPath fillRect:[self bounds]];
    
    // stroke coordinate axes
    if ([(EDGraph *)[self dataObj] hasCoordinateAxes]) {
        NSBezierPath *path = [NSBezierPath bezierPath];
        float height = [self frame].size.height;
        float width = [self frame].size.width;
        [[NSColor blackColor] setStroke];
        
        //draw x-axis
        [path moveToPoint:NSMakePoint(0, height/2)];
        [path lineToPoint:NSMakePoint(width, height/2)];
        
        // draw y-axis
        [path moveToPoint:NSMakePoint(width/2, 0)];
        [path lineToPoint:NSMakePoint(width/2, height)];
        
        [path setLineWidth:EDGraphDefaultCoordinateLineWidth];
        [path stroke];
    }
}

@end