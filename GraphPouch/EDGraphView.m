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
    NSRect bounds = NSMakeRect(10, 10, 20, 20);
    
    // fill color based on selection
    if ([[self dataObj] isSelectedElement]){
        [[NSColor redColor] set];
    }
    else {
        [[NSColor greenColor] set];
    }
    [NSBezierPath fillRect:bounds];
    
    [super drawRect:dirtyRect];
}

@end