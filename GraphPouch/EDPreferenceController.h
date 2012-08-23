//
//  EDPreferenceController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 8/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EDPreferenceController : NSWindowController{
    IBOutlet NSButton *snapToGrid;
}

+ (BOOL)preferenceSnapToGuides;
+ (void)setPreferenceSnapToGuides:(BOOL)snap;
- (IBAction)changeSnapToGuides:(id)sender;

@end
