//
//  EDSheetPropertiesGraphErrorController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 1/20/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDSheetPropertiesGraphErrorController.h"

@interface EDSheetPropertiesGraphErrorController ()

@end

@implementation EDSheetPropertiesGraphErrorController

- (id)initWithContext:(NSManagedObjectContext *)context;
{
    self = [super initWithWindowNibName:@"EDSheetPropertiesGraphError"];
    if (self) {
        // init code:w
        _context = context;
    }
    
    return self;
}

- (IBAction)onButtonPressedOk:(id)sender{
    [NSApp endSheet:[self window]];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    //[fieldError setStringValue:_errorMsg];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}


- (void)initializeSheet:(NSString *)errorMessage{
    [fieldError setStringValue:errorMessage];
}
@end
