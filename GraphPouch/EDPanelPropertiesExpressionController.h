//
//  EDPanelPropertiesExpressionController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 4/15/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDPanelViewController.h"

@interface EDPanelPropertiesExpressionController : EDPanelViewController <NSTextFieldDelegate>{
    IBOutlet NSTextField *labelX;
    IBOutlet NSTextField *labelY;
    IBOutlet NSTextField *labelWidth;
    IBOutlet NSTextField *labelHeight;
    IBOutlet NSTextField *labelExpression;
    IBOutlet NSTextField *labelFontSize;
    IBOutlet NSSlider *sliderFontSize;
    IBOutlet NSButton *checkboxAutoresize;
}

@property (nonatomic) float fontSize;

- (IBAction)toggleAutoresize:(id)sender;
@end
