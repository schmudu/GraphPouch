//
//  EDPageViewContainerExpressionView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 4/20/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDExpression.h"

@interface EDPageViewContainerExpressionView : NSView{
    EDExpression *_expression;
    NSManagedObjectContext *_context;
}

- (id)initWithFrame:(NSRect)frame expression:(EDExpression *)expression context:(NSManagedObjectContext *)context;
- (EDExpression *)expression;

@end
