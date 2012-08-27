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
        //NSLog(@"setting state to:%@", [defaults boolForKey:EDPreferenceSnapToGuides]);
        //[snapToGrid setState:[defaults boolForKey:EDPreferenceSnapToGuides]];
    }
    return self;
}

- (void)menuWillOpen:(NSMenu *)menu{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:EDPreferenceSnapToGuides]) {
        [snapToGrid setState:NSOnState];
    }
    else {
        [snapToGrid setState:NSOffState];
    }
}

- (IBAction)toggleSnapToGrid:(id)sender{
    // toggle the state
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // toggle
    if ([snapToGrid state]){
        [defaults setBool:FALSE forKey:EDPreferenceSnapToGuides];
        [snapToGrid setState:NSOffState];
    }
    else {
        [defaults setBool:TRUE forKey:EDPreferenceSnapToGuides];
        [snapToGrid setState:NSOnState];
    }
}
@end
