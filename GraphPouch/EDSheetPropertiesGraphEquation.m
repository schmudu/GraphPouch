//
//  EDSheetPropertiesGraphEquation.m
//  GraphPouch
//
//  Created by PATRICK LEE on 12/3/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDSheetPropertiesGraphEquation.h"
#import "EDConstants.h"

@implementation EDSheetPropertiesGraphEquation

- (BOOL)performKeyEquivalent:(NSEvent *)theEvent{
    if ([theEvent keyCode] == EDKeycodeQuit) {
        [[NSNotificationCenter defaultCenter] postNotificationName:EDEventQuitDuringEquationSheet object:self];
        return TRUE;
    }
    return FALSE;
}

@end
