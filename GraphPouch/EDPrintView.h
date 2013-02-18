//
//  EDPrintView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 2/17/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EDPrintView : NSView{
    NSManagedObjectContext *_context;
    NSMutableArray *_elements;
}

- (id)initWithFrame:(NSRect)frame context:(NSManagedObjectContext *)context;
@end
