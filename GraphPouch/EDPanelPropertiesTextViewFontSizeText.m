//
//  EDPanelPropertiesTextViewFontSizeText.m
//  GraphPouch
//
//  Created by PATRICK LEE on 2/10/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDPanelPropertiesTextViewFontSizeText.h"
#import "EDConstants.h"

@implementation EDPanelPropertiesTextViewFontSizeText

- (void)controlTextDidChange:(NSNotification *)obj{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventControlDidChange object:self];
}
@end
