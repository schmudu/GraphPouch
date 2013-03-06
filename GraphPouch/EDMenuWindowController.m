//
//  EDMenuWindowController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 8/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDMenuWindowController.h"
#import "EDConstants.h"
#import "NSObject+Document.h"
#import "EDDocument.h"

@interface EDMenuWindowController ()

@end

@implementation EDMenuWindowController


- (void)menuWillOpen:(NSMenu *)menu{
    //if ([(EDDocument *)[self currentDocument] propertiesPanelIsOpen]){
    /*
    if ([[NSUserDefaults standardUserDefaults] boolForKey:EDPreferencePropertyPanel]){
        [properties setState:NSOnState];
    }
    else {
        [properties setState:NSOffState];
    }*/
}

@end
