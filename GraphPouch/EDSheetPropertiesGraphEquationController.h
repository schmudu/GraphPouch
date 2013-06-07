//
//  EDSheetPropertiesGraphEquationController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 11/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDEquation.h"

@interface EDSheetPropertiesGraphEquationController : NSWindowController <NSTextFieldDelegate, NSWindowDelegate>{
    IBOutlet NSButton *buttonCancel;
    IBOutlet NSButton *buttonSubmit;
    IBOutlet NSTextField *fieldEquation;
    IBOutlet NSTextField *errorField;
    IBOutlet NSPopUpButton *buttonType;
    NSManagedObjectContext *_context;
    NSString *_newEquation;
    int _equationIndex;
    NSString *_equationOriginalString;
}

- (IBAction)onButtonPressedCancel:(id)sender;
- (IBAction)onButtonPressedSubmit:(id)sender;
- (id)initWithContext:(NSManagedObjectContext *)context;
//- (void)initializeSheet:(NSString *)equation index:(int)index;
- (void)initializeSheet:(EDEquation *)equation index:(int)index;
- (IBAction)onButtonPressedHelp:(id)sender;
+ (NSString *)equationTypeFromInt:(int)typeInt;
- (IBAction)onButtonEquationTypeSelected:(id)sender;
    
@end
