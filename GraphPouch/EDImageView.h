//
//  EDImageView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 4/22/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDWorksheetElementView.h"
@class EDImage;

@interface EDImageView : EDWorksheetElementView{
}

- (id)initWithFrame:(NSRect)frame imageModel:(EDImage *)myImage;

@end
