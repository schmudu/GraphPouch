//
//  EDMenuViewController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 8/24/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EDMenuViewController : NSObject{
    IBOutlet NSMenuItem *snapToGrid;
}

- (IBAction)changeSnapToGrid:(id)sender;

@end
