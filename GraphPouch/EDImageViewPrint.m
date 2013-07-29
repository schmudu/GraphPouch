//
//  EDImageViewPrint.m
//  GraphPouch
//
//  Created by PATRICK LEE on 6/27/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDImageViewPrint.h"
#import "EDImage.h"

@implementation EDImageViewPrint

- (id)initWithFrame:(NSRect)frame imageModel:(EDImage *)myImage{
    self = [super initWithFrame:frame imageModel:myImage];
    if (self){
        [self drawElementAttributes];
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

- (void)drawElementAttributes{
    NSImage *image = [[NSImage alloc] initWithData:[(EDImage *)[self dataObj] imageData]];
    [image setSize:NSMakeSize([(EDImage *)[self dataObj] elementWidth], [(EDImage *)[self dataObj] elementHeight])];
    _imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, [(EDImage *)[self dataObj] elementWidth], [(EDImage *)[self dataObj] elementHeight])];
    [_imageView setImage:image];
    [self addSubview:_imageView];
}

- (void)removeFeatures{
    [_imageView removeFromSuperview];
}
@end
