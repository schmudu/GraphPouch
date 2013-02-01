//
//  EDTextField.m
//  GraphPouch
//
//  Created by PATRICK LEE on 2/1/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDTextField.h"
#import "EDConstants.h"

@implementation EDTextField

- (BOOL)becomeFirstResponder{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventControlReceivedFocus object:self];
    return [super becomeFirstResponder];
}

@end
