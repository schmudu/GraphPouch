//
//  EDSheetPropertiesGraphErrorController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 1/20/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EDSheetPropertiesGraphErrorController : NSWindowController{
    IBOutlet NSButton *buttonOk;
    IBOutlet NSTextField *fieldError;
    NSManagedObjectContext *_context;
    NSString *_errorMsg;
}

- (IBAction)onButtonPressedOk:(id)sender;
- (void)initializeSheet:(NSString *)errorMessage;
- (id)initWithContext:(NSManagedObjectContext *)context;
@end
