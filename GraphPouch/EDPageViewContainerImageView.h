//
//  EDPageViewContainerImageView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 4/22/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDImage.h"

@interface EDPageViewContainerImageView : NSView{
    EDImage *_image;
    NSManagedObjectContext *_context;
}

- (id)initWithFrame:(NSRect)frame image:(EDImage *)image context:(NSManagedObjectContext *)context;
- (EDImage *)image;

@end
