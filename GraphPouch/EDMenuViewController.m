//
//  EDMenuViewController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 8/24/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDMenuViewController.h"
#import "EDConstants.h"

@implementation EDMenuViewController

- (id)init{
    self = [super init];
    if (self){
        // set snap to grid based on default preferences
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [snapToGrid setState:[defaults boolForKey:EDPreferenceSnapToGuides]];
    }
    return self;
}

- (IBAction)changeSnapToGrid:(id)sender{
    // toggle the state
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger snapToGridFlag = [defaults boolForKey:EDPreferenceSnapToGuides];
    
    // toggle
    if (snapToGridFlag) {
        [defaults setBool:FALSE forKey:EDPreferenceSnapToGuides];
        [snapToGrid setState:NSOffState];
    }
    else {
        [defaults setBool:TRUE forKey:EDPreferenceSnapToGuides];
        [snapToGrid setState:NSOnState];
    }
}

@end
