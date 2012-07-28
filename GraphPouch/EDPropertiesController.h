//
//  EDPropertiesController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/27/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDPropertiesViewControllerGraph.h"
#import "EDPropertiesViewControllerText.h"

@interface EDPropertiesController : NSWindowController{
    IBOutlet NSView *contentView;
    NSMutableArray *viewControllers;
    EDPropertiesViewControllerGraph *viewControllerGraph;
    EDPropertiesViewControllerText *viewControllerText;
}

//- (IBAction)changeViewControllers:(id)sender;
- (IBAction)showPropertiesPanel:(id)sender;
- (IBAction)showPropertiesPanelText:(id)sender;

@end
