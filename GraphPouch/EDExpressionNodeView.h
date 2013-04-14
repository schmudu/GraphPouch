//
//  EDExpressionNodeView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 4/11/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDExpression.h"
#import "EDToken.h"
#import "EDWorksheetElementView.h"

@interface EDExpressionNodeView : EDWorksheetElementView{
    float _fontModifier;
    EDExpression *_expression;
}
@property int treeHeight;
@property (nonatomic, retain) NSImage *image;
@property (nonatomic, retain) EDToken *token;
@property (nonatomic, retain) EDExpressionNodeView *childLeft, *childRight;
@property (nonatomic, weak) EDExpressionNodeView *parent;

+ (EDExpressionNodeView *)createExpressionNodeTree:(NSArray *)stack frame:(NSRect)frame expression:(EDExpression *)expression;
+ (NSSize)getTokenSize:(EDToken *)token fontSize:(float)fontSize;
+ (NSImage *)getTokenImage:(EDToken *)token fontSize:(float)fontSize;
+ (NSTextField *)generateTextField:(NSRect)rect;
- (id)initWithFrame:(NSRect)frameRect expression:(EDExpression *)expression token:(EDToken *)token;
- (EDToken *)token;
- (void)traverseTreeAndCreateImage;
- (BOOL)insertNodeIntoRightMostChild:(EDExpressionNodeView *)node;
- (BOOL)isLeafNode;

@end
