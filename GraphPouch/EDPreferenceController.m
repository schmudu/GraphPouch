//
//  EDPreferenceController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 8/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPreferenceController.h"
#import "EDConstants.h"

@interface EDPreferenceController ()

@end

@implementation EDPreferenceController

- (id)init{
    self = [super initWithWindowNibName:@"Preferences"];
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    NSLog(@"Nib file is loaded");
    [snapToGrid setState:[EDPreferenceController preferenceSnapToGuides]];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

#pragma mark preferences
#pragma mark snap to guides

+ (BOOL)preferenceSnapToGuides{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:EDPreferenceSnapToGuides];
}

+ (void)setPreferenceSnapToGuides:(BOOL)snap{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:snap forKey:EDPreferenceSnapToGuides];
}

- (IBAction)changeSnapToGuides:(id)sender{
    NSInteger state = [snapToGrid state];
    [EDPreferenceController setPreferenceSnapToGuides:state];
}
@end
