//
//  EDAppController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 8/21/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class EDPreferenceController;

@interface EDAppController : NSObject <NSApplicationDelegate>{
    EDPreferenceController *preferencesController;
}
- (IBAction)showPreferencePanel:(id)sender;

@end
