//
//  EDWindow.h
//  GraphPouch
//
//  Created by PATRICK LEE on 8/19/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EDWindow : NSWindow{
    NSManagedObjectContext *_context;
}

- (void)postInitialize:(NSManagedObjectContext *)context;

@end
