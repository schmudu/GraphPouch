//
//  EDPanelPropertiesGraphTableEquation.h
//  GraphPouch
//
//  Created by PATRICK LEE on 12/16/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EDPanelPropertiesGraphTableEquation : NSObject <NSTableViewDataSource, NSTableViewDelegate>{
    NSManagedObjectContext *_context;
    NSTableView *equationTable;
    NSButton *buttonEquationRemove;
}

- (id)initWithContext:(NSManagedObjectContext *)context table:(NSTableView *)table removeButton:(NSButton *)button;
@end