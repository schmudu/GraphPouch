//
//  EDSheetPropertiesGraphError.m
//  GraphPouch
//
//  Created by PATRICK LEE on 1/20/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDSheetPropertiesGraphError.h"

#import "EDConstants.h"

@implementation EDSheetPropertiesGraphError

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent{
    if ([theEvent keyCode] == EDKeycodeQuit) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EDEventQuitDuringEquationSheet object:self];
        return TRUE;
    }
    return [super performKeyEquivalent:theEvent];
}

- (void)cancelOperation:(id)sender{
    [NSApp endSheet:self];
}

@end
