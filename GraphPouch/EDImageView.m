//
//  EDImageView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 4/22/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDImage.h"
#import "EDImageView.h"
#import "NSColor+Utilities.h"

@interface EDImageView()
- (void)onContextChanged:(NSNotification *)note;
@end


@implementation EDImageView

- (id)initWithFrame:(NSRect)frame imageModel:(EDImage *)myImage{
    self = [super initWithFrame:frame];
    if (self){
        _context = [myImage managedObjectContext];
        
        // set model info
        [self setDataObj:myImage];
        
        /*
        // set image
        NSImage *image = [[NSImage alloc] initWithData:[(EDImage *)[self dataObj] imageData]];
        _imageView = [[NSImageView alloc] initWithFrame:[self frame]];
        [_imageView setImage:image];
         */
        
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

- (void)drawElementAttributes{
    /*
    NSImage *image = [[NSImage alloc] initWithData:[(EDImage *)[self dataObj] imageData]];
    _imageView = [[NSImageView alloc] initWithFrame:[self frame]];
    [_imageView setImage:image];
     */
    //[self addSubview:_imageView];
}

- (void)removeFeatures{
    //[_imageView removeFromSuperview];
}

- (void)drawRect:(NSRect)dirtyRect
{
    // do this for real time re-sizing
    NSImage *image = [[NSImage alloc] initWithData:[(EDImage *)[self dataObj] imageData]];
    [image drawInRect:[self bounds] fromRect:NSZeroRect operation:NSCompositeSourceAtop fraction:1.0 respectFlipped:TRUE hints:nil];
}

/*
- (void)updateDisplayBasedOnContext{
    // this is called whenever the context for this object changes
    [super updateDisplayBasedOnContext];
 
    [self removeFeatures];
    [self drawElementAttributes];
}*/
@end
