//
//  EDExpressionView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 4/15/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDExpression.h"
#import "EDExpressionNodeView.h"
#import "EDWorksheetElementView.h"

@interface EDExpressionView : EDWorksheetElementView{
    EDExpressionNodeView *_rootNodeFirst, *_rootNodeSecond;
    BOOL _drawSeleection;
}

+ (EDExpressionNodeView *)createExpressionNodeTree:(NSArray *)stack frame:(NSRect)frame expression:(EDExpression *)expression;
- (id)initWithFrame:(NSRect)frameRect expression:(EDExpression *)expression drawSelection:(BOOL)drawSelection;
- (void)clearViews;
@end
