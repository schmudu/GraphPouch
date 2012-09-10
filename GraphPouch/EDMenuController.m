//
//  EDMenuController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 9/9/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDMenuController.h"
#import "EDMenuWindowPropertiesController.h"
#import "EDConstants.h"

@implementation EDMenuController

- (id)init{
    self = [super init];
    if(!propertiesController){
        propertiesController = [[EDMenuWindowPropertiesController alloc] init];
    }
    return self;
}

- (IBAction)togglePropertiesPanel:(id)sender{
    [[[NSDocumentController sharedDocumentController] currentDocument] togglePropertiesPanel:sender];
}
@end
