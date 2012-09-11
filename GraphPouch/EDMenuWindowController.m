//
//  EDMenuWindowController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 8/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDMenuWindowController.h"
#import "EDPanelPropertiesController.h"
#import "EDConstants.h"

@interface EDMenuWindowController ()

@end

@implementation EDMenuWindowController


- (void)menuWillOpen:(NSMenu *)menu{
    NSLog(@"menu did open.");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:EDPreferencePropertyPanel]) {
        [properties setState:NSOnState];
    }
    else {
        [properties setState:NSOffState];
    }
}

@end
