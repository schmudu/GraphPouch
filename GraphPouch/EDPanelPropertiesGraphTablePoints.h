//
//  EDPanelPropertiesGraphTablePoints.h
//  GraphPouch
//
//  Created by PATRICK LEE on 11/4/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EDPanelPropertiesGraphTablePoints : NSTableView <NSTableViewDataSource, NSTableViewDelegate>{
    NSManagedObjectContext *_context;
    NSTableView *pointsTable;
    NSButton *buttonPointRemove;
    BOOL _changedPointAttribute;
}

- (id)initWithContext:(NSManagedObjectContext *)context table:(NSTableView *)table removeButton:(NSButton *)button;
@end
