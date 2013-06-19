//
//  EDPanelPropertiesGraphTableEquation.h
//  GraphPouch
//
//  Created by PATRICK LEE on 12/16/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EDFormatterDecimalUnsigned.h"

@interface EDPanelPropertiesGraphTableEquation : NSTableView <NSTableViewDataSource, NSTableViewDelegate>{
    NSManagedObjectContext *_context;
    NSTableView *equationTable;
    NSButton *buttonEquationRemove;
    NSButton *buttonEquationExport;
    EDFormatterDecimalUnsigned *alphaFormatter;
}

- (id)initWithContext:(NSManagedObjectContext *)context table:(NSTableView *)table removeButton:(NSButton *)removeButton exportButton:(NSButton *)exportButton;
@end