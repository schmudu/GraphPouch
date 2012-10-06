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

@interface EDGraphView()

@end

@implementation EDGraphView
//@synthesize graph;

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
    if ([[self dataObj] isSelectedElement]){
        [[NSColor redColor] set];
    }
    else {
        [[NSColor greenColor] set];
    }
    
    [NSBezierPath fillRect:[self bounds]];
}

@end