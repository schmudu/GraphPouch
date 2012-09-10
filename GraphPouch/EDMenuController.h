//
//  EDMenuController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 9/9/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDMenuWindowPropertiesController.h"

@interface EDMenuController : NSObject{
    EDMenuWindowPropertiesController *propertiesController;
}
- (IBAction)togglePropertiesPanel:(id)sender;

@end
