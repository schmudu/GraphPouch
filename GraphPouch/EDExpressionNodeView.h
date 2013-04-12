//
//  EDExpressionNodeView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 4/11/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDToken.h"
#import "EDWorksheetElementView.h"

@interface EDExpressionNodeView : EDWorksheetElementView{
    EDExpressionNodeView *_childLeft, *_childRight, *_parent;
    float _fontModifier, _fontSize;
    int _treeHeight;
}
@property int treeHeight;
@property float fontModifier, fontSize;
@property (nonatomic, retain) EDToken *token;
@property (nonatomic, retain) EDExpressionNodeView *childLeft, *childRight;
@property (nonatomic, weak) EDExpressionNodeView *parent;

+ (NSSize)getTokenSize:(EDToken *)token fontSize:(float)fontSize;
+ (NSImage *)getTokenImage:(EDToken *)token fontSize:(float)fontSize;
+ (NSTextField *)generateTextField:(NSRect)rect;
- (id)initWithFrame:(NSRect)frameRect token:(EDToken *)token;
- (EDToken *)token;
- (BOOL)insertNodeIntoRightMostChild:(EDExpressionNodeView *)node;
- (BOOL)isLeafNode;

@end
