//
//  EDAppController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 8/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDAppController.h"
#import "EDPreferenceController.h"
#import "EDConstants.h"

@implementation EDAppController

+ (void)initialize{
    // Create a dictionary
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
    
    // Archive the snapToGrid
    //NSData *snapAsData = [NSKeyedArchiver archivedDataWithRootObject:TRUE];
    
    // Put the defaults in the dictionary
    [defaultValues setObject:[NSNumber numberWithBool:TRUE] forKey:EDPreferenceSnapToGuides];
    
    // Register defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
    NSLog(@"registered defaults: %@", defaultValues);
}

- (IBAction)showPreferencePanel:(id)sender{
    // is preferenceController nil?
    if (!preferencesController){
        preferencesController = [[EDPreferenceController alloc] init];
    }
    
    NSLog(@"showing %@", preferencesController);
    [preferencesController showWindow:self];
}
@end
