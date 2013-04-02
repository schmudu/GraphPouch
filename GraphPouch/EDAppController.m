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
    // init app code
    NSLog(@"initialize.");
}

- (IBAction)showPreferencePanel:(id)sender{
    // is preferenceController nil?
    if (!preferencesController){
        preferencesController = [[EDPreferenceController alloc] init];
    }
    
    [preferencesController showWindow:self];
}

#pragma mark application delegate
@end
