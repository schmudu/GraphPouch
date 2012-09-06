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

@interface EDGraphView()

@end

@implementation EDGraphView
//@synthesize graph;

- (id)initWithFrame:(NSRect)frame graphModel:(EDGraph *)myGraph{
    self = [super initWithFrame:frame];
    if (self){
        //generate id
        [self setViewID:[EDGraphView generateID]];
        
        // listen
        EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
        NSManagedObjectContext *context = [coreData context];
        
        // listen
        _nc = [NSNotificationCenter defaultCenter];
        [_nc addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:context];
        
        // set model info
        [self setDataObj:myGraph];
    }
    return self;
}

- (void) dealloc{
    EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
    NSManagedObjectContext *context = [coreData context];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_nc removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:context];
}

- (void)drawRect:(NSRect)dirtyRect
{
    //NSRect bounds = [self bounds];
    //NSRect bounds = NSMakeRect(0, 0, [[self dataObj] elementWidth], [[self dataObj] elementHeight]);
    [self setFrameSize:NSMakeSize([[self dataObj] elementWidth], [[self dataObj] elementHeight])];
    //NSRect bounds = NSMakeRect([[self dataObj] locationX], [[self dataObj] locationY], [[self dataObj] elementWidth], [[self dataObj] elementHeight]);
    //[self setBounds:NSMakeRect(0, 0, [[self dataObj] elementWidth], [[self dataObj] elementHeight])];
    
    // fill color based on selection
    if ([[self dataObj] isSelectedElement]){
        [[NSColor redColor] set];
    }
    else {
        [[NSColor greenColor] set];
    }
    
    //[NSBezierPath fillRect:bounds];
    [NSBezierPath fillRect:NSMakeRect(0, 0, [self bounds].size.width, [self bounds].size.height)]; 
    NSLog(@"bound width :%f frame width:%f data width:%f", [self bounds].size.width, [self frame].size.width, [[self dataObj] elementWidth]);
    
    //[super drawRect:dirtyRect];
}

@end