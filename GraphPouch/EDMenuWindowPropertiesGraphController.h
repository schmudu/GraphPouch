//
//  EDMenuWindowPropertiesGraphController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 8/29/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDPanelViewController.h"

@interface EDMenuWindowPropertiesGraphController : EDPanelViewController <NSTextFieldDelegate>{
    IBOutlet NSTextField *labelWidth;
    IBOutlet NSTextField *labelX;
}
@end
