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
- (void)applicationWillFinishLaunching:(NSNotification *)notification{
    NSLog(@"app will finished launching: current document:%@", [[NSDocumentController sharedDocumentController] currentDocument]);
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification{
    NSApplication *mainApp = (NSApplication *)[notification object];
    NSLog(@"app did finished launching: current document:%@ notification:%@", [[NSDocumentController sharedDocumentController] currentDocument], [[NSApplication sharedApplication] mainWindow]);
}

- (BOOL)applicationOpenUntitledFile:(NSApplication *)sender{
    NSLog(@"application will open file.");
    return TRUE;
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename{
    NSLog(@"application will open file:%@", filename);
    return TRUE;
}

- (BOOL)application:(NSApplication *)sender openTempFile:(NSString *)filename{
    NSLog(@"application will open temp file:%@", filename);
    return TRUE;
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag{
    NSLog(@"application should handle reopen.");
    return TRUE;
}
@end
