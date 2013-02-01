//
//  EDLineView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 1/31/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDLineView.h"
#import "EDConstants.h"
#import "NSColor+Utilities.h"
#import "EDLine.h"

@interface EDLineView()
- (void)onContextChanged:(NSNotification *)note;

@end

@implementation EDLineView

- (id)initWithFrame:(NSRect)frame lineModel:(EDLine *)myLine{
    self = [super initWithFrame:frame];
    if (self){
        _context = [myLine managedObjectContext];
        
        // set model info
        [self setDataObj:myLine];
        
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
    // draw line in the middle of the bounds
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path setLineWidth:[[(EDLine *)[self dataObj] thickness] floatValue]];
    [[NSColor redColor] setStroke];
                        
    [path moveToPoint:NSMakePoint(0, [self bounds].size.height/2)];
    [path lineToPoint:NSMakePoint([self bounds].size.width, [self bounds].size.height/2)];
    
    [path stroke];
    
    // color background
    if ([(EDLine *)[self dataObj] selected]){
        [[NSColor colorWithHexColorString:EDGraphSelectedBackgroundColor alpha:EDGraphSelectedBackgroundAlpha] set];
        [NSBezierPath fillRect:[self bounds]];
    }
}

@end
