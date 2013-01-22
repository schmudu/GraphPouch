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
}

- (void)initializeSheet:(NSString *)errorMessage{
    _errorMsg = errorMessage;
    [fieldError setStringValue:errorMessage];
}

#pragma mark window delegate
- (void)awakeFromNib{
    // init error message
    [fieldError setStringValue:_errorMsg];
}
@end
