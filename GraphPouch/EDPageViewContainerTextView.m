//
//  EDPageViewContainerTextView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 3/14/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDPageViewContainerTextView.h"
#import "EDConstants.h"
#import "EDTextboxView.h"

@implementation EDPageViewContainerTextView
- (id)initWithFrame:(NSRect)frame textbox:(EDTextbox *)textbox context:(NSManagedObjectContext *)context{
    self = [super initWithFrame:frame];
    if (self) {
        _textbox = textbox;
        _context = context;
        
        float xRatio = EDPageImageViewWidth/EDWorksheetViewWidth;
        float yRatio = EDPageImageViewHeight/EDWorksheetViewHeight;
        
        EDTextboxView *textboxView = [[EDTextboxView alloc] initWithFrame:NSMakeRect(0, 0, [_textbox elementWidth], [_textbox elementHeight]) textboxModel:_textbox drawSelection:TRUE];
        
        // scale image to page view container
        NSRect thumbnailRect = NSMakeRect(0, 0, [_textbox elementWidth] * xRatio, [_textbox elementHeight] * yRatio);
        NSImage *expressionImage = [[NSImage alloc] initWithData:[textboxView dataWithPDFInsideRect:[textboxView frame]]];
        NSImageView *imageViewExpression = [[NSImageView alloc] initWithFrame:thumbnailRect];
        [imageViewExpression setImageScaling:NSScaleProportionally];
        [imageViewExpression setImage:expressionImage];
        
        // add expression view to stage
        [self addSubview:imageViewExpression];
        
        // position it
        [self setFrameOrigin:NSMakePoint([_textbox locationX] * xRatio, [_textbox locationY] * yRatio)];
    }
    
    return self;
}

- (BOOL)isFlipped{
    return TRUE;
}
@end
