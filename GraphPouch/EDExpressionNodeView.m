//
//  EDExpressionNodeView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 4/11/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDExpressionNodeView.h"

@interface EDExpressionNodeView()
- (float)fontSize;
@end

@implementation EDExpressionNodeView

@synthesize treeHeight, token, childLeft, childRight, parent;

- (BOOL)isFlipped{
    return TRUE;
}

- (float)fontSize{
    return [_expression fontSize];
}

- (float)fontModifier{
    return _fontModifier;
}

- (void)setFontModifier:(float)fontModifier{
    _fontModifier = fontModifier;
    
    // reset frame size
    [self setFrameSize:[EDExpressionNodeView getTokenSize:[self token] fontSize:([self fontSize]*_fontModifier)]];
}

- (id)initWithFrame:(NSRect)frameRect token:(EDToken *)newToken expression:(EDExpression *)expression{
    self = [super initWithFrame:frameRect];
    if (self) {
        _expression = expression;
        [self setToken:newToken];
        [self setChildLeft:nil];
        [self setChildRight:nil];
        [self setFontModifier:1.0];
        [self setTreeHeight:0];
        
        // set default text size
    }
    
    return self;
}

+ (NSTextField *)generateTextField:(NSRect)rect{
    NSTextField *returnField = [[NSTextField alloc] initWithFrame:rect];
    [returnField setEditable:FALSE];
    [returnField setSelectable:FALSE];
    [returnField setBordered:FALSE];
    [returnField setDrawsBackground:FALSE];
    return returnField;
}

- (void)drawRect:(NSRect)dirtyRect
{
    if ([[self token] typeRaw] == EDTokenTypeOperator){
        if (([[[self token] tokenValue] isEqualToString:@"+"]) || ([[[self token] tokenValue] isEqualToString:@"-"])){
            NSPoint point = NSMakePoint([[self childLeft] frame].size.width, 0);
            [[self image] drawAtPoint:point fromRect:NSZeroRect operation:NSCompositeSourceAtop fraction:1.0];
        }
        else if ([[[self token] tokenValue] isEqualToString:@"/"]){
            float largerWidth;
            largerWidth = MAX([[self childLeft] frame].size.width, [[self childRight] frame].size.width);
            
            // draw division line
            NSBezierPath *path = [NSBezierPath bezierPath];
            [[NSColor blackColor] setStroke];
            [path moveToPoint:NSMakePoint(0, [[self childLeft] frame].size.height + 1)];
            [path lineToPoint:NSMakePoint(largerWidth, [[self childLeft] frame].size.height + 1)];
            [path stroke];
        }
    }
    else if (([[self token] typeRaw] == EDTokenTypeIdentifier) || ([[self token] typeRaw] == EDTokenTypeNumber)){
        NSRect rect = NSMakeRect(0, 0, [self frame].size.width, [self frame].size.height);
        [[self image] drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceAtop fraction:1.0 respectFlipped:TRUE hints:nil];
    }
}

#pragma tokens
+ (NSImage *)getTokenImage:(EDToken *)token fontSize:(float)fontSize{
    NSTextField *field;
    NSMutableAttributedString *string;
    NSData *imageData;
    NSImage *image;
    
    NSSize size = [EDExpressionNodeView getTokenSize:token fontSize:fontSize];
    field = [EDExpressionNodeView generateTextField:NSMakeRect(0, 0, size.width, size.height)];
    string = [[NSMutableAttributedString alloc] initWithString:[token tokenValue]];
    [field setFont:[NSFont fontWithName:EDExpressionDefaultFontName size:fontSize]];
    [field setAttributedStringValue:string];
    imageData = [field dataWithPDFInsideRect:NSMakeRect(0, 0, size.width, size.height)];
    image = [[NSImage alloc] initWithData:imageData];
    NSLog(@"token image:%@ size:%f", [token tokenValue], fontSize);
    return image;
}

+ (NSSize)getTokenSize:(EDToken *)token fontSize:(float)fontSize{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSFont *font = [NSFont fontWithName:EDExpressionDefaultFontName size:fontSize];
    [dict setObject:font forKey:NSFontAttributeName];
    NSSize size = [[token tokenValue] sizeWithAttributes:dict];
    return NSMakeSize(size.width + 3, size.height);
}

#pragma tree
- (BOOL)insertNodeIntoRightMostChild:(EDExpressionNodeView *)node{
    BOOL result = FALSE;
    if (![self isLeafNode]){
        if (![self childRight]){
                // insert right if nothing there
                [self setChildRight:node];
                [node setParent:self];
                [node setTreeHeight:[self treeHeight]+1];
            
            // if parent is a divide op then cut font modifier in half
            if ([[[self token] tokenValue] isEqualToString:@"/"]){
                [node setFontModifier:[self fontModifier] * EDExpressionFontModifierDenominator];
                //NSLog(@"setting font of token:%@ to modifier:%f", [[node token] tokenValue], [node fontModifier]);
            }
            else if ([[[self token] tokenValue] isEqualToString:@"^"])
                [node setFontModifier:[self fontModifier] * EDExpressionFontModifierExponentialPower];
            else
                [node setFontModifier:[self fontModifier]];
            
            return TRUE;
        }
        
        // try inserting under right child
        result = [[self childRight] insertNodeIntoRightMostChild:node];
        
        // insert left if nothing there
        if(result) return TRUE;
        if (![self childLeft]){
                // insert right if nothing there
                [self setChildLeft:node];
                [node setParent:self];
                [node setTreeHeight:[self treeHeight]+1];
            
            // if parent is a divide op then cut font modifier in half
            if ([[[self token] tokenValue] isEqualToString:@"/"])
                [node setFontModifier:[self fontModifier] * EDExpressionFontModifierNumerator];
            else if ([[[self token] tokenValue] isEqualToString:@"^"])
                [node setFontModifier:[self fontModifier] * EDExpressionFontModifierExponentialBase];
            else
                [node setFontModifier:[self fontModifier]];
            
            return TRUE;
        }
        
        // try inserting under right child
        result = [[self childLeft] insertNodeIntoRightMostChild:node];
        if(result) return TRUE;
    }
    
    return FALSE;
}

- (BOOL)isLeafNode{
    if (([[self token] typeRaw] == EDTokenTypeNumber) || ([[self token] typeRaw] == EDTokenTypeIdentifier)){
        return TRUE;
    }
    return FALSE;
}

- (void)traverseTreeAndCreateImage{
    // traverse right
    if([self childRight]) [[self childRight] traverseTreeAndCreateImage];
    
    // traverse left
    if([self childLeft]) [[self childLeft] traverseTreeAndCreateImage];
    
    // create image
    if (([[self token] typeRaw] == EDTokenTypeNumber) || ([[self token] typeRaw] == EDTokenTypeIdentifier)){
        [self setImage:[EDExpressionNodeView getTokenImage:[self token] fontSize:([self fontSize]*[self fontModifier])]];
    }
    else if ([[self token] typeRaw] == EDTokenTypeOperator){
        // height and width
        float heightLeft = [[self childLeft] frame].size.height;
        float heightRight = [[self childRight] frame].size.height;
        float largerHeight = MAX(heightLeft, heightRight);
        float widthLeft = [[self childLeft] frame].size.width;
        float widthRight = [[self childRight] frame].size.width;
        float largerWidth = MAX(widthLeft, widthRight);
        
        if (([[[self token] tokenValue] isEqualToString:@"+"]) || ([[[self token] tokenValue] isEqualToString:@"-"])){
            // left child
            [self addSubview:[self childLeft]];
            
            // image of operator
            [self setImage:[EDExpressionNodeView getTokenImage:[self token] fontSize:([self fontSize]*[self fontModifier])]];
            
            // right child
            [self addSubview:[self childRight]];
            [[self childRight] setFrameOrigin:NSMakePoint([[self childLeft] frame].size.width + [[self image] size].width, 0)];
            
            //NSLog(@"token:%@ width left:%f self:%f right:%f", [[self token] tokenValue], [[self childLeft] frame].size.width, [self frame].size.width, [[self childRight] frame].size.width);
            [self setFrameSize:NSMakeSize([[self childLeft] frame].size.width + [[self image] size].width + [[self childRight] frame].size.width, largerHeight)];
            //NSLog(@"new frame size:%f", [self frame].size.width);
        }
        else if([[[self token] tokenValue] isEqualToString:@"/"]){
            float height = heightLeft + 1 + 2 + 1 + heightRight;
            [self addSubview:[self childLeft]];
            
            // center left child
            if (widthLeft > widthRight)
                [[self childLeft] setFrameOrigin:NSMakePoint(0, 0)];
            else{
                //[[self childRight] setFrameOrigin:NSMakePoint((largerWidth-widthLeft)/2, 0)];
                [[self childLeft] setFrameOrigin:NSMakePoint((largerWidth-widthLeft)/2, 0)];
            }
            
            //right child
            [self addSubview:[self childRight]];
            
            // center left child
            if (widthRight > widthLeft)
                [[self childRight] setFrameOrigin:NSMakePoint(0, 1+2+1+heightLeft)];
            else{
                //[[self childLeft] setFrameOrigin:NSMakePoint((largerWidth-widthLeft)/2, 1+2+1+heightLeft)];
                [[self childRight] setFrameOrigin:NSMakePoint(0, 1+2+1+heightLeft)];
            }
            
            // reset frame size
            [self setFrameSize:NSMakeSize(largerWidth, height)];
            //NSLog(@"divide op: height left:%f self:%f right:%f", [[self childLeft] frame].size.height, 4.0, [[self childRight] frame].size.height);
        }
    }
}

- (void)clearViews{
    // traverse right
    if([self childRight]){
        [[self childRight] clearViews];
        [[self childRight] removeFromSuperview];
    }
    
    // traverse left
    if([self childLeft]){
        [[self childLeft] clearViews];
        [[self childRight] removeFromSuperview];
    }
    
    // remove any other subviews
    for (NSView *view in [self subviews]){
        [view removeFromSuperview];
    }
}

@end
