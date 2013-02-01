//
//  EDTextboxView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 2/1/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//
#import "EDTextboxView.h"
#import "EDConstants.h"
#import "NSColor+Utilities.h"
#import "EDTextbox.h"

@interface EDTextboxView()
- (void)onContextChanged:(NSNotification *)note;

@end

@implementation EDTextboxView
- (id)initWithFrame:(NSRect)frame textboxModel:(EDTextbox *)myTextbox{
    self = [super initWithFrame:frame];
    if (self){
        _context = [myTextbox managedObjectContext];
        
        // set model info
        [self setDataObj:myTextbox];
        
        // listen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    }
    return self;
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
}

- (BOOL)isFlipped{
    return TRUE;
}

- (void)onContextChanged:(NSNotification *)note{
    // this enables undo method to work
    NSArray *updatedArray = [[[note userInfo] objectForKey:NSUpdatedObjectsKey] allObjects];
    
    BOOL hasChanged = FALSE;
    int i = 0;
    NSManagedObject *element;
    
    // search through updated array and see if this element has changed
    while ((i<[updatedArray count]) && (!hasChanged)){
        element = [updatedArray objectAtIndex:i];
        // if data object changed or any of the points, update graph
        if (element == [self dataObj]){
            hasChanged = TRUE;
            [self updateDisplayBasedOnContext];
        }
        i++;
    }
}

- (void)drawRect:(NSRect)dirtyRect
{
    // draw rect code
    [[NSColor redColor] setFill];
    [NSBezierPath fillRect:[self bounds]];
}

@end