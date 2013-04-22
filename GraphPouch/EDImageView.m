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
- (void)removeImage;
- (void)drawImage;
@end


@implementation EDImageView

- (id)initWithFrame:(NSRect)frame imageModel:(EDImage *)myImage drawSelection:(BOOL)drawSelection{
    self = [super initWithFrame:frame];
    if (self){
        _drawSelection = drawSelection;
        _context = [myImage managedObjectContext];
        
        // set model info
        [self setDataObj:myImage];
        
        // draw image on startup
        [self removeImage];
        [self drawImage];
        
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
    // color background
    if ((_drawSelection) && ([(EDImage *)[self dataObj] selected])){
        [[NSColor colorWithHexColorString:EDGraphSelectedBackgroundColor alpha:EDGraphSelectedBackgroundAlpha] set];
        [NSBezierPath fillRect:[self bounds]];
    }
}

- (void)updateDisplayBasedOnContext{
    [super updateDisplayBasedOnContext];
 
    [self removeImage];
    [self drawImage];
}

#pragma mark image
- (void)removeImage{
    if (_image) {
        [_image removeFromSuperview];
    }
}

- (void)drawImage{
    NSImage *image = [[NSImage alloc] initWithData:[(EDImage *)[self dataObj] imageData]];
    NSImageView *imageView = [[NSImageView alloc] initWithFrame:[self bounds]];
    [imageView setImageScaling:NSScaleProportionally];
    [imageView setImage:image];
    [self addSubview:imageView];
    
    // scale image to page view container
    /*
    NSRect thumbnailRect = NSMakeRect(0, 0, [_line elementWidth] * xRatio, [_line elementHeight] * yRatio);
    NSImage *lineImage = [[NSImage alloc] initWithData:[graphView dataWithPDFInsideRect:[graphView frame]]];
    NSImageView *imageViewLine = [[NSImageView alloc] initWithFrame:thumbnailRect];
    [imageViewLine setImageScaling:NSScaleProportionally];
    [imageViewLine setImage:lineImage];
     */
    
    // save image to remove later
    _image = imageView;
}
@end
