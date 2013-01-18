//
//  EDMainContentView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 1/17/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDWorksheetView.h"

@interface EDMainContentView : NSView{
    IBOutlet EDWorksheetView *_worksheetView;
}

-(void)windowDidResize;
@end
