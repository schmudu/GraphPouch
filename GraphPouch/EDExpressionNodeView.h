//
//  EDExpressionNodeView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 4/11/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDExpression.h"
#import "EDToken.h"

@interface EDExpressionNodeView : NSView{
    float _fontModifier;
    EDExpression *_expression;
}
@property int treeHeight;
@property (nonatomic, retain) NSImage *image;
@property (nonatomic, retain) EDToken *token;
@property (nonatomic, retain) EDExpressionNodeView *childLeft, *childRight;
@property (nonatomic, weak) EDExpressionNodeView *parent;

+ (NSSize)getTokenSize:(EDToken *)token fontSize:(float)fontSize;
+ (NSImage *)getTokenImage:(EDToken *)token fontSize:(float)fontSize;
+ (NSTextField *)generateTextField:(NSRect)rect;
- (id)initWithFrame:(NSRect)frameRect token:(EDToken *)newToken expression:(EDExpression *)expression;
- (EDToken *)token;
- (void)traverseTreeAndCreateImage;
- (BOOL)insertNodeIntoRightMostChild:(EDExpressionNodeView *)node;
- (BOOL)isLeafNode;
- (void)clearViews;

@end
