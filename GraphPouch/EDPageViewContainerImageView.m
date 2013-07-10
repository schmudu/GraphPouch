//
//  EDPageViewContainerImageView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 4/22/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDPageViewContainerImageView.h"
#import "EDConstants.h"
#import "EDImageView.h"

@implementation EDPageViewContainerImageView

- (id)initWithFrame:(NSRect)frame image:(EDImage *)image context:(NSManagedObjectContext *)context
{
    self = [super initWithFrame:frame];
    if (self) {
        _image = image;
        _context = context;
        
        float xRatio = EDPageImageViewWidth/EDWorksheetViewWidth;
        float yRatio = EDPageImageViewHeight/EDWorksheetViewHeight;
        
        EDImageView *imageView = [[EDImageView alloc] initWithFrame:NSMakeRect(0, 0, [_image elementWidth], [_image elementHeight]) imageModel:image];
        
        // scale image to page view container
        NSRect thumbnailRect = NSMakeRect(0, 0, [_image elementWidth] * xRatio, [_image elementHeight] * yRatio);
        NSImage *imageOfImage = [[NSImage alloc] initWithData:[imageView dataWithPDFInsideRect:[imageView frame]]];
        NSImageView *imageViewImage = [[NSImageView alloc] initWithFrame:thumbnailRect];
        [imageViewImage setImageScaling:NSScaleProportionally];
        [imageViewImage setImage:imageOfImage];
        
        // add expression view to stage
        [self addSubview:imageViewImage];
        
        // position it
        [self setFrameOrigin:NSMakePoint([_image locationX] * xRatio, [_image locationY] * yRatio)];
    }
    
    return self;
}
- (EDImage *)image{
    return _image;
}

- (BOOL)isFlipped{
    return TRUE;
}
@end
