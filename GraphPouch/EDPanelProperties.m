//
//  EDPanelProperties.m
//  GraphPouch
//
//  Created by PATRICK LEE on 1/11/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDPanelProperties.h"
#import "EDConstants.h"

@implementation EDPanelProperties

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent{
    if ([theEvent keyCode] == EDKeycodeSave) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EDEventShortcutSave object:self];
    }
    return NO;
}
@end
