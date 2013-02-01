//
//  EDLineView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 1/31/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDWorksheetElementView.h"
@class EDLine;

@interface EDLineView : EDWorksheetElementView

- (id)initWithFrame:(NSRect)frame lineModel:(EDLine *)myLine;
@end
