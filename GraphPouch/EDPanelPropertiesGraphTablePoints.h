//
//  EDPanelPropertiesGraphTablePoints.h
//  GraphPouch
//
//  Created by PATRICK LEE on 11/4/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EDPanelPropertiesGraphTablePoints : NSObject <NSTableViewDataSource, NSTableViewDelegate>{
    NSManagedObjectContext *_context;
    IBOutlet NSTableView *pointsTable;
}

@end
