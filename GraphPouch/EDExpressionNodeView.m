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

@synthesize treeHeight, token, childLeft, childRight, parent, baseline;


- (id)initWithFrame:(NSRect)frameRect token:(EDToken *)newToken expression:(EDExpression *)expression{
    self = [super initWithFrame:frameRect];
    if (self) {
        _expression = expression;
        [self setToken:newToken];
        [self setChildLeft:nil];
        [self setChildRight:nil];
        [self setFontModifier:1.0];
        [self setTreeHeight:0];
        _addedSubviewsOtherThanRightAndLeftChildren = [NSMutableArray array];
    }
    
    return self;
}

- (BOOL)isFlipped{
    return TRUE;
}

#pragma mark getters/setters
- (EDExpression *)expression{
    return _expression;
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
    [self setFrameSize:[EDExpressionNodeView getStringSize:[[self token] tokenValue] fontSize:([self fontSize]*_fontModifier)]];
}

+ (float)fontSizeForString:(NSString *)string height:(float)height{
    // find font size for the string that matches the height
    NSSize size;
    float testFontSize = EDExpressionFontSizeMinimum;
    float fontSizeIncrement = 1.0;
    while (testFontSize < EDExpressionFontSizeMaximum){
        size = [EDExpressionNodeView getStringSize:string fontSize:testFontSize];
        
        if (size.height > height)
            return testFontSize;
        
        testFontSize += fontSizeIncrement;
    }
    
    // by default return maximum font size
    return EDExpressionFontSizeMaximum;
}

+ (NSTextField *)generateTextField:(float)fontSize string:(NSString *)string{
    NSSize size = [EDExpressionNodeView getStringSize:string fontSize:fontSize];
    NSTextField *returnField;
    
    // for some reason the size does not return an accurate width and the characters wrap around to the next line
    if ([string length] > 1)
        returnField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, size.width+EDExpressionTextFieldEndBuffer, size.height)];
    else
        returnField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, size.width-size.width*.05, size.height)];
    
    [returnField setEditable:FALSE];
    [returnField setSelectable:FALSE];
    [returnField setBordered:FALSE];
    [returnField setDrawsBackground:FALSE];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [returnField setFont:[NSFont fontWithName:EDExpressionDefaultFontName size:fontSize]];
    [returnField setAttributedStringValue:attributedString];
    return returnField;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // height and width
    float heightLeft = [[self childLeft] frame].size.height;
    float heightRight = [[self childRight] frame].size.height;
    float largerHeight = MAX(heightLeft, heightRight);
    float widthLeft = [[self childLeft] frame].size.width;
    float widthRight = [[self childRight] frame].size.width;
    float largerWidth = MAX(widthLeft, widthRight);
    
    if ([[self token] typeRaw] == EDTokenTypeOperator){
        if (([[[self token] tokenValue] isEqualToString:@"+"]) || ([[[self token] tokenValue] isEqualToString:@"-"])){
            // do nothing, all of it is done in traverse tree
        }
        else if ([[[self token] tokenValue] isEqualToString:@"/"]){
            // draw division line
            NSBezierPath *path = [NSBezierPath bezierPath];
            [[NSColor blackColor] setStroke];
            [path moveToPoint:NSMakePoint(0, [[self childLeft] frame].size.height + 1)];
            [path lineToPoint:NSMakePoint(largerWidth, [[self childLeft] frame].size.height + 1)];
            [path stroke];
        }
        else if ([[[self token] tokenValue] isEqualToString:@"*"]){
            // do nothing for multiplication, all of it is done in traverse tree
        }
        else if ([[[self token] tokenValue] isEqualToString:@"^"]){
            // do nothing for multiplication, all of it is done in traverse tree
            if ([[[[self childRight] token] tokenValue] isEqualToString:@"/"]){
                //if ([[[self childLeft] token] typeRaw] == EDTokenTypeOperator){
                    // get the size of the right child's right child (aka grandchild)
                    // draw division line
                    NSBezierPath *path = [NSBezierPath bezierPath];
                    [[NSColor blackColor] setStroke];
                    
                    // line above the base, left to right
                    [path moveToPoint:NSMakePoint([[self childLeft] frame].origin.x - _radicalBaseLeftParenWidth, _radicalRootHeight + EDExpressionRadicalPowerOffsetVertical)];
                    [path lineToPoint:NSMakePoint([[self childLeft] frame].origin.x - _radicalBaseLeftParenWidth + _radicalBaseWidth, _radicalRootHeight + EDExpressionRadicalPowerOffsetVertical)];
                
                    // line from origin of line over base to bottom, right to left
                    [path moveToPoint:NSMakePoint([[self childLeft] frame].origin.x - _radicalBaseLeftParenWidth, _radicalRootHeight + EDExpressionRadicalPowerOffsetVertical)];
                    [path lineToPoint:NSMakePoint([[self childLeft] frame].origin.x - _radicalBaseLeftParenWidth - [self fontSize]*[self fontModifier]*EDExpressionRadicalLineWidthTertiary, [[self childLeft] frame].size.height*EDExpressionRadicalLineHeightTertiary + _radicalRootHeight)];
                    [path lineToPoint:NSMakePoint([[self childLeft] frame].origin.x - _radicalBaseLeftParenWidth - [self fontSize]*[self fontModifier]*EDExpressionRadicalLineWidthSecondary, [[self childLeft] frame].size.height * .7 + _radicalRootHeight)];
                    [path lineToPoint:NSMakePoint([[self childLeft] frame].origin.x - _radicalBaseLeftParenWidth - [self fontSize]*[self fontModifier]*EDExpressionRadicalLineWidthPrimary, [[self childLeft] frame].size.height * .7 + _radicalRootHeight)];
                    [path stroke];
                //}
            }
            else if ([[[self childRight] token] typeRaw] == EDTokenTypeOperator){
                // do nothing, work done in traverse tree
            }
        }
        else if ([[[self childRight] token] typeRaw] == EDTokenTypeOperator){
            // do nothing
        }
        else{
            // do nothing
            // number/identifier raised to something
        }
        
    }
    else if (([[self token] typeRaw] == EDTokenTypeIdentifier) || ([[self token] typeRaw] == EDTokenTypeNumber)){
        // traverseTree method will add the identifier
    }
}

#pragma tokens
+ (NSImage *)getTokenImage:(EDToken *)token fontSize:(float)fontSize{
    NSTextField *field;
    //NSMutableAttributedString *string;
    NSData *imageData;
    NSImage *image;
    
    NSSize size = [EDExpressionNodeView getStringSize:[token tokenValue] fontSize:fontSize];
    field = [EDExpressionNodeView generateTextField:fontSize string:[token tokenValue]];
    imageData = [field dataWithPDFInsideRect:NSMakeRect(0, 0, size.width, size.height)];
    image = [[NSImage alloc] initWithData:imageData];
    return image;
}

+ (NSSize)getStringSize:(NSString *)string fontSize:(float)fontSize{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSFont *font = [NSFont fontWithName:EDExpressionDefaultFontName size:fontSize];
    [dict setObject:font forKey:NSFontAttributeName];
    NSSize size = [string sizeWithAttributes:dict];
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
    
    // print out token
    //NSLog(@"traverse tree: token:%@ height:%d left token:%@ right token:%@", [token tokenValue], [self treeHeight], [[childLeft token] tokenValue], [[childRight token] tokenValue]);
    // create image
    if (([[self token] typeRaw] == EDTokenTypeNumber) || ([[self token] typeRaw] == EDTokenTypeIdentifier)){
        // every node view has a baseline, see x-height article on wikipedia.org for more info
        NSTextField *field = [EDExpressionNodeView generateTextField:[[self expression] fontSize]*[self fontModifier] string:[token tokenValue]];
        [self addSubview:field];
        [self setBaseline:[field frame].size.height];
        [self setFrameSize:NSMakeSize([field frame].size.width, [field frame].size.height)];
    }
    else if ([[self token] typeRaw] == EDTokenTypeOperator){
        // height and width
        float heightLeft = [[self childLeft] frame].size.height;
        float heightRight = [[self childRight] frame].size.height;
        float largerHeight = MAX(heightLeft, heightRight);
        float widthLeft = [[self childLeft] frame].size.width;
        float widthRight = [[self childRight] frame].size.width;
        float largerWidth = MAX(widthLeft, widthRight);
        NSSize sizeChildLeft = [[self childLeft] frame].size, sizeChildRight = [[self childRight] frame].size;
        if (([[[self token] tokenValue] isEqualToString:@"+"]) || ([[[self token] tokenValue] isEqualToString:@"-"])){
            // set baseline
            if (([[childLeft token] typeRaw] == EDTokenTypeIdentifier) || ([[childLeft token] typeRaw] == EDTokenTypeNumber))
                [self setBaseline:[childLeft baseline]];
            else if(([[childRight token] typeRaw] == EDTokenTypeIdentifier) || ([[childRight token] typeRaw] == EDTokenTypeNumber))
                [self setBaseline:[childRight baseline]];
            else
                [self setBaseline:[childLeft baseline]];
            
            // left child
            [self addSubview:[self childLeft]];
            //[[self childLeft] setFrameOrigin:NSMakePoint(0, (largerHeight-heightLeft)/2)];
            [[self childLeft] setFrameOrigin:NSMakePoint(0, [self baseline] - sizeChildLeft.height)];
            
            // add addition/subtraction oeprator
            float fontSize = [self fontModifier] * [self fontSize];
            NSSize sizeOperator = [EDExpressionNodeView getStringSize:@"x" fontSize:fontSize];
            NSTextField *fieldOperator = [EDExpressionNodeView generateTextField:fontSize string:[[self token] tokenValue]];
            [self addSubview:fieldOperator];
            //[fieldOperator setFrameOrigin:NSMakePoint(widthLeft, (largerHeight - sizeOperator.height)/2)];
            [fieldOperator setFrameOrigin:NSMakePoint(widthLeft, ([self baseline] - sizeOperator.height)/2)];
            [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldOperator];
        
            // right child
            [self addSubview:[self childRight]];
            //[[self childRight] setFrameOrigin:NSMakePoint([[self childLeft] frame].size.width + sizeOperator.width, (largerHeight-heightRight)/2)];
            [[self childRight] setFrameOrigin:NSMakePoint([[self childLeft] frame].size.width + sizeOperator.width, [self baseline] - sizeChildRight.height)];
            
            [self setFrameSize:NSMakeSize([[self childLeft] frame].size.width + sizeOperator.width + [[self childRight] frame].size.width, largerHeight)];
            
        }
        else if([[[self token] tokenValue] isEqualToString:@"/"]){
            float height = heightLeft + 1 + 1 + 1 + heightRight;
            [self addSubview:[self childLeft]];
            
            // center left child
            if (widthLeft > widthRight)
                [[self childLeft] setFrameOrigin:NSMakePoint(0, 0)];
            else{
                [[self childLeft] setFrameOrigin:NSMakePoint((largerWidth-widthLeft)/2, 0)];
            }
            
            //right child
            [self addSubview:[self childRight]];
            
            // center left child
            if (widthRight > widthLeft)
                [[self childRight] setFrameOrigin:NSMakePoint(0, 1+1+1+heightLeft)];
            else{
                [[self childRight] setFrameOrigin:NSMakePoint((largerWidth-widthRight)/2, 1+1+1+heightLeft)];
            }
            
            // reset frame size
            [self setFrameSize:NSMakeSize(largerWidth, height)];
            //NSLog(@"divide op: height left:%f self:%f right:%f", [[self childLeft] frame].size.height, 4.0, [[self childRight] frame].size.height);
            //NSLog(@"divide op: setting height to:%f right token:%@", height, [[[self childRight] token] tokenValue]);
        }
        else if([[[self token] tokenValue] isEqualToString:@"*"]){
            if (([[[self childLeft] token] typeRaw] == EDTokenTypeOperator) && ([[[self childRight] token] typeRaw] == EDTokenTypeOperator)){
                // two operators, need to surround right and left child with parenthesis
                float parenWidthLeft, parenWidthRight, childWidthLeft, childWidthRight, fontSize;
                NSSize sizeParenLeft, sizeParenRight;
                
                // determine font size if it's a divide operation
                if ([[[[self childLeft] token] tokenValue] isEqualToString:@"/"])
                    fontSize = [EDExpressionNodeView fontSizeForString:@"(" height:[[self childLeft] frame].size.height];
                else
                    fontSize = [[self expression] fontSize]*[[self childLeft] fontModifier];
                    
                // add left paren
                sizeParenLeft = [EDExpressionNodeView getStringSize:@"(" fontSize:fontSize];
                NSTextField *fieldLeftParen = [EDExpressionNodeView generateTextField:fontSize string:@"("];
                [self addSubview:fieldLeftParen];
                [fieldLeftParen setFrameOrigin:NSMakePoint(0, (largerHeight-heightLeft)/2)];
                [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldLeftParen];
                parenWidthLeft = [fieldLeftParen frame].size.width;
                
                // left child
                [self addSubview:[self childLeft]];
                [[self childLeft] setFrameOrigin:NSMakePoint(parenWidthLeft, (largerHeight-heightLeft)/2)];
                childWidthLeft = [[self childLeft] frame].size.width;
                
                sizeParenRight = [EDExpressionNodeView getStringSize:@")" fontSize:fontSize];
                NSTextField *fieldRightParen = [EDExpressionNodeView generateTextField:fontSize string:@")"];
                [self addSubview:fieldRightParen];
                [fieldRightParen setFrameOrigin:NSMakePoint(parenWidthLeft + childWidthLeft, (largerHeight-heightLeft)/2)];
                [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldRightParen];
                
                // determine font size if it's a divide operation
                if ([[[[self childRight] token] tokenValue] isEqualToString:@"/"])
                    fontSize = [EDExpressionNodeView fontSizeForString:@"(" height:[[self childRight] frame].size.height];
                else
                    fontSize = [[self expression] fontSize]*[[self childRight] fontModifier];
                    
                // add left paren
                sizeParenLeft = [EDExpressionNodeView getStringSize:@"(" fontSize:fontSize];
                NSTextField *fieldSecondLeftParen = [EDExpressionNodeView generateTextField:fontSize string:@"("];
                [self addSubview:fieldSecondLeftParen];
                [fieldSecondLeftParen setFrameOrigin:NSMakePoint(parenWidthLeft + childWidthLeft + parenWidthLeft, (largerHeight-heightRight)/2)];
                [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldSecondLeftParen];
                parenWidthRight = [fieldSecondLeftParen frame].size.width;
                
                // right child
                [self addSubview:[self childRight]];
                [[self childRight] setFrameOrigin:NSMakePoint(parenWidthLeft + childWidthLeft + parenWidthLeft + parenWidthRight, (largerHeight-heightRight)/2)];
                childWidthRight = [[self childRight] frame].size.width;
                
                // add second right paren
                sizeParenRight = [EDExpressionNodeView getStringSize:@")" fontSize:fontSize];
                NSTextField *fieldSecondRightParen = [EDExpressionNodeView generateTextField:fontSize string:@")"];
                [self addSubview:fieldSecondRightParen];
                [fieldSecondRightParen setFrameOrigin:NSMakePoint(parenWidthLeft + childWidthLeft + parenWidthLeft + parenWidthRight + childWidthRight, (largerHeight-heightRight)/2)];
                [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldSecondRightParen];
                
                
                [self setFrameSize:NSMakeSize(parenWidthLeft + childWidthLeft + parenWidthLeft + parenWidthRight + childWidthRight + parenWidthRight, largerHeight)];
            }
            else if (([[[self childLeft] token] typeRaw] == EDTokenTypeOperator) || ([[[self childRight] token] typeRaw] == EDTokenTypeOperator)){
                // one of the children is an operator and the other one is an identifier/number
                // need to surround the operator with parenthesis
                float parenWidthLeft, parenWidthRight, childWidthLeft, childWidthRight, fontSize;
                EDExpressionNodeView *childOperator, *childIdentifierNumber;
                NSSize sizeParenLeft, sizeParenRight;
                
                if ([[[self childLeft] token] typeRaw] == EDTokenTypeOperator){
                    childOperator = [self childLeft];
                    childIdentifierNumber = [self childRight];
                }
                else{
                    childOperator = [self childRight];
                    childIdentifierNumber = [self childLeft];
                }
                
                // need to figure out if the divisor is a common fraction
                if (([[[childOperator token] tokenValue] isEqualToString:@"/"]) && ([[[childOperator childLeft] token] typeRaw] == EDTokenTypeNumber) && ([[[childOperator childRight] token] typeRaw] == EDTokenTypeNumber)){
                    // we have a fraction divisor in front of a identifier/number
                    // determine larger height
                    float heightOperator = [childOperator frame].size.height;
                    float heightIdentifierNumber = [childIdentifierNumber frame].size.height;
                    float largerHeight = MAX(heightOperator, heightIdentifierNumber);
                    
                    if ([[childIdentifierNumber token] typeRaw] == EDTokenTypeIdentifier){
                        // child operator
                        [self addSubview:childOperator];
                        [childOperator setFrameOrigin:NSMakePoint(0, (largerHeight-heightOperator)/2)];
                        childWidthLeft = [childOperator frame].size.width;
                        
                        // child identifier/number
                        [self addSubview:childIdentifierNumber];
                        [childIdentifierNumber setFrameOrigin:NSMakePoint(childWidthLeft, (largerHeight-heightIdentifierNumber)/2)];
                        childWidthRight = [childIdentifierNumber frame].size.width;
                        [self setFrameSize:NSMakeSize(childWidthLeft + childWidthRight, largerHeight)];
                    }
                    else{
                        // left child operator
                        [self addSubview:childOperator];
                        [childOperator setFrameOrigin:NSMakePoint(0, (largerHeight-heightOperator)/2)];
                        childWidthLeft = [childOperator frame].size.width;
                        
                        // add multiply symbol
                        float fontSize = [self fontSize] * [self fontModifier] * .8;
                        NSSize sizeOperator = [EDExpressionNodeView getStringSize:@"x" fontSize:fontSize];
                        NSTextField *fieldMultiply = [EDExpressionNodeView generateTextField:fontSize string:@"x"];
                        [self addSubview:fieldMultiply];
                        [fieldMultiply setFrameOrigin:NSMakePoint(childWidthLeft, (largerHeight - sizeOperator.height)/2)];
                        float widthOperator = [fieldMultiply frame].size.width;
                        [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldMultiply];
                            
                        // right child
                        [self addSubview:childIdentifierNumber];
                        [childIdentifierNumber setFrameOrigin:NSMakePoint(childWidthLeft + widthOperator, (largerHeight-heightIdentifierNumber)/2)];
                        childWidthRight = [childIdentifierNumber frame].size.width;
                        [self setFrameSize:NSMakeSize(childWidthLeft + widthOperator + childWidthRight, largerHeight)];
                    }
                }
                else if ([[[childOperator token] tokenValue] isEqualToString:@"^"]){
                    // multiply an identifier/number with an exponent
                    NSSize sizeOperator = [childOperator frame].size;
                    NSSize sizeIdentifierNumber = [childIdentifierNumber frame].size;
                    float largerHeight = MAX(sizeOperator.height, sizeIdentifierNumber.height);
                    
                    // left child identifier/number
                    [self addSubview:childIdentifierNumber];
                    [childIdentifierNumber setFrameOrigin:NSMakePoint(0, (largerHeight-sizeIdentifierNumber.height)/2)];
                    
                    // right child
                    [self addSubview:childOperator];
                    [childOperator setFrameOrigin:NSMakePoint(sizeIdentifierNumber.width, (largerHeight-sizeOperator.height)/2)];
                    [self setFrameSize:NSMakeSize(sizeOperator.width + sizeIdentifierNumber.width, largerHeight)];
                }
                else if ([[[childOperator token] tokenValue] isEqualToString:@"*"]){
                    // determine larger height
                    NSSize sizeOperator = [childOperator frame].size;
                    NSSize sizeIdentifierNumber = [childIdentifierNumber frame].size;
                    float largerHeight = MAX(sizeOperator.height, sizeIdentifierNumber.height);
                    
                    // just multiply tokens together
                    // left child operator
                    [self addSubview:childOperator];
                    [childOperator setFrameOrigin:NSMakePoint(0, (largerHeight-sizeOperator.height)/2)];
                                                          
                    // add multiply symbol
                    float fontSize = [self fontSize] * [self fontModifier] * EDExpressionSymbolMultiplicationSymbolFontModifier;
                    NSSize sizeMultiply = [EDExpressionNodeView getStringSize:@"x" fontSize:fontSize];
                    NSTextField *fieldMultiply = [EDExpressionNodeView generateTextField:fontSize string:@"x"];
                    [self addSubview:fieldMultiply];
                    [fieldMultiply setFrameOrigin:NSMakePoint(widthLeft, 0)];
                    [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldMultiply];
                        
                    // right child
                    [self addSubview:childIdentifierNumber];
                    [childIdentifierNumber setFrameOrigin:NSMakePoint(sizeOperator.width + sizeMultiply.width, (largerHeight-sizeIdentifierNumber.height)/2)];
                    [self setFrameSize:NSMakeSize(sizeOperator.width + sizeMultiply.width + sizeIdentifierNumber.width, largerHeight)];
                }
                else{
                    // determine larger height
                    float heightOperator = [childOperator frame].size.height;
                    float heightIdentifierNumber = [childIdentifierNumber frame].size.height;
                    float largerHeight = MAX(heightOperator, heightIdentifierNumber);
                    
                    // determine font size if it's a divide operation
                    if ([[[childOperator token] tokenValue] isEqualToString:@"/"])
                        fontSize = [EDExpressionNodeView fontSizeForString:@"(" height:[childOperator frame].size.height];
                    else
                        fontSize = [[self expression] fontSize]*[childOperator fontModifier];
                    
                    // child identifier/number
                    [self addSubview:childIdentifierNumber];
                    [childIdentifierNumber setFrameOrigin:NSMakePoint(0, (largerHeight-heightIdentifierNumber)/2)];
                    childWidthLeft = [childIdentifierNumber frame].size.width;
                    
                    // add left paren
                    sizeParenLeft = [EDExpressionNodeView getStringSize:@"(" fontSize:fontSize];
                    NSTextField *fieldLeftParen = [EDExpressionNodeView generateTextField:fontSize string:@"("];
                    [self addSubview:fieldLeftParen];
                    [fieldLeftParen setFrameOrigin:NSMakePoint(childWidthLeft, (largerHeight-sizeParenLeft.height)/2)];
                    [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldLeftParen];
                    parenWidthLeft = [fieldLeftParen frame].size.width;
                    
                    // child operator
                    [self addSubview:childOperator];
                    [childOperator setFrameOrigin:NSMakePoint(childWidthLeft + parenWidthLeft, (largerHeight-heightOperator)/2)];
                    childWidthRight = [childOperator frame].size.width;
                    
                    // add right paren
                    sizeParenRight = [EDExpressionNodeView getStringSize:@")" fontSize:fontSize];
                    NSTextField *fieldRightParen = [EDExpressionNodeView generateTextField:fontSize string:@")"];
                    [self addSubview:fieldRightParen];
                    [fieldRightParen setFrameOrigin:NSMakePoint(childWidthLeft + parenWidthLeft + childWidthRight, (largerHeight-sizeParenLeft.height)/2)];
                    [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldRightParen];
                    parenWidthRight = [fieldRightParen frame].size.width;
                    
                    [self setFrameSize:NSMakeSize(childWidthLeft + parenWidthLeft + childWidthRight + parenWidthRight, largerHeight)];
                }
            }
            else if ((([[[self childLeft] token] typeRaw] == EDTokenTypeNumber) && ([[[[self childLeft] token] tokenValue] isEqualToString:@"-1"]))&&
                     (([[[self childRight] token] typeRaw] == EDTokenTypeIdentifier) || ([[[self childRight] token] typeRaw] == EDTokenTypeNumber))){
                // a negative one token multiplied by an identifier/number
                // combine into a negative identifier/number
                float fontSize = [self fontSize] * [self fontModifier] * EDExpressionSymbolMultiplicationSymbolFontModifier;
                
                // right child
                // show right child as negative
                NSTextField *newRightChild = [EDExpressionNodeView generateTextField:fontSize string:[NSString stringWithFormat:@"-%@", [[[self childRight] token] tokenValue]]];
                
                [self addSubview:newRightChild];
                [_addedSubviewsOtherThanRightAndLeftChildren addObject:newRightChild];
                
                [self setFrameSize:NSMakeSize([newRightChild frame].size.width, [newRightChild frame].size.height)];
            }
            else if ((([[[self childLeft] token] typeRaw] == EDTokenTypeNumber) && ([[[self childRight] token] typeRaw] == EDTokenTypeNumber)) ||
                     (([[[self childLeft] token] typeRaw] == EDTokenTypeIdentifier) && ([[[self childRight] token] typeRaw] == EDTokenTypeIdentifier))){
                // two identifiers/numbers, place multiplication symbol in between
                float childWidthLeft, childWidthRight;
                float fontSize = [self fontSize] * [self fontModifier] * EDExpressionSymbolMultiplicationSymbolFontModifier;
                NSSize sizeOperator;
                
                // left child
                [self addSubview:[self childLeft]];
                [[self childLeft] setFrameOrigin:NSMakePoint(0, 0)];
                childWidthLeft = [[self childLeft] frame].size.width;
                
                // add multiply symbol
                sizeOperator = [EDExpressionNodeView getStringSize:@"x" fontSize:fontSize];
                NSTextField *fieldMultiply = [EDExpressionNodeView generateTextField:fontSize string:@"x"];
                [self addSubview:fieldMultiply];
                [fieldMultiply setFrameOrigin:NSMakePoint(childWidthLeft, 0)];
                [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldMultiply];
                
                // right child
                [self addSubview:[self childRight]];
                [[self childRight] setFrameOrigin:NSMakePoint(childWidthLeft + sizeOperator.width, 0)];
                childWidthRight = [[self childRight] frame].size.width;
                
                [self setFrameSize:NSMakeSize(childWidthLeft + sizeOperator.width + childWidthRight, largerHeight)];
            }
            else{
                // one child is an identifier and the other is a number
                // put the number in front
                float childWidthLeft, childWidthRight;
                EDExpressionNodeView *childNumber, *childIdentifier;
                
                if ([[[self childLeft] token] typeRaw] == EDTokenTypeNumber){
                    childNumber = [self childLeft];
                    childIdentifier = [self childRight];
                }
                else{
                    childNumber = [self childRight];
                    childIdentifier = [self childLeft];
                }
                
                // left child
                [self addSubview:childNumber];
                childWidthLeft = [childNumber frame].size.width;
                
                // right child
                [self addSubview:childIdentifier];
                [childIdentifier setFrameOrigin:NSMakePoint(childWidthLeft, 0)];
                childWidthRight = [[self childRight] frame].size.width;
                
                [self setFrameSize:NSMakeSize(childWidthLeft + childWidthRight, [childNumber frame].size.height)];
            }
        }
        else if([[[self token] tokenValue] isEqualToString:@"^"]){
            if ([[[[self childRight] token] tokenValue] isEqualToString:@"/"]){
                if ([[[self childLeft] token] typeRaw] == EDTokenTypeOperator){
                    // draw the base surrounded by parenthesis with the numerator exponent and a root symbol
                    float parenWidthLeft=0, parenWidthRight=0, childWidthLeft=0, widthRadicalRoot=0, widthRadicalPower=0, fontSize=0;
                    NSSize sizeParenLeft, sizeParenRight, sizeRadicalRoot, sizeRadicalPower;
                    EDExpressionNodeView *radicalPower = [[self childRight] childLeft];
                    EDExpressionNodeView *radicalRoot = [[self childRight] childRight];
                    sizeRadicalPower = [[[self childRight] childLeft] frame].size;
                    sizeRadicalRoot = [[[self childRight] childRight] frame].size;
                    _radicalBaseWidth = 0;
                    _radicalBaseLeftParenWidth = 0;
                    
                    // determine font size if it's a divide operation
                    fontSize = [EDExpressionNodeView fontSizeForString:@"(" height:[[self childLeft] frame].size.height];
                    
                    // radical root
                    // if radical root is 2, then don't show it
                    if ([[[radicalRoot token] tokenValue] isEqualToString:@"2"]){
                    }
                    else{
                        [self addSubview:radicalRoot];
                        [_addedSubviewsOtherThanRightAndLeftChildren addObject:radicalRoot];
                        widthRadicalRoot = sizeRadicalRoot.width;
                        _radicalBaseWidth += widthRadicalRoot;
                        _radicalRootHeight = sizeRadicalRoot.height-EDExpressionRadicalRootLowerLeftOriginOffset;
                    }
                    
                    // this is where the radical sign and the rest of the elements start drawing, so give it a bit of a buffer/offset
                    _radicalRootWidth = sizeRadicalRoot.width+EDExpressionRadicalRootUpperLeftOriginOffset;
                    [radicalRoot setFrameOrigin:NSMakePoint(0, 0)];
                    
                    // left paren
                    if ([[[radicalPower token] tokenValue] isEqualToString:@"1"]){
                        // dont surround with parenthesis if power is 1
                    }
                    else{
                        sizeParenLeft = [EDExpressionNodeView getStringSize:@"(" fontSize:fontSize];
                        NSTextField *fieldLeftParen = [EDExpressionNodeView generateTextField:fontSize string:@"("];
                        [self addSubview:fieldLeftParen];
                        [fieldLeftParen setFrameOrigin:NSMakePoint(_radicalRootWidth, (_radicalRootHeight + EDExpressionRadicalPowerOffsetVertical))];
                        [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldLeftParen];
                        parenWidthLeft = [fieldLeftParen frame].size.width;
                        _radicalBaseWidth += parenWidthLeft;
                        _radicalBaseLeftParenWidth = parenWidthLeft;
                    }
                    
                    // radical base
                    [self addSubview:childLeft];
                    childWidthLeft = [childLeft frame].size.width;
                    _radicalBaseWidth += childWidthLeft;
                    [childLeft setFrameOrigin:NSMakePoint(_radicalRootWidth + parenWidthLeft, _radicalRootHeight + EDExpressionRadicalPowerOffsetVertical)];
                    
                    // add right paren
                    if ([[[radicalPower token] tokenValue] isEqualToString:@"1"]){
                        // dont surround with parenthesis if power is 1
                    }
                    else{
                        sizeParenRight = [EDExpressionNodeView getStringSize:@")" fontSize:fontSize];
                        NSTextField *fieldRightParen = [EDExpressionNodeView generateTextField:fontSize string:@")"];
                        [self addSubview:fieldRightParen];
                        [fieldRightParen setFrameOrigin:NSMakePoint(_radicalRootWidth + parenWidthLeft + childWidthLeft, _radicalRootHeight + EDExpressionRadicalPowerOffsetVertical)];
                        [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldRightParen];
                        parenWidthRight = [fieldRightParen frame].size.width;
                        _radicalBaseWidth += parenWidthRight;
                    }
                    
                    // if radical power is 1 then don't show it
                    if ([[[radicalPower token] tokenValue] isEqualToString:@"1"]){
                    }
                    else{
                        [self addSubview:radicalPower];
                        [_addedSubviewsOtherThanRightAndLeftChildren addObject:radicalPower];
                        widthRadicalPower = sizeRadicalPower.width;
                        _radicalBaseWidth += widthRadicalPower;
                        _radicalPowerHeight = sizeRadicalPower.height;
                        [radicalPower setFrameOrigin:NSMakePoint(_radicalRootWidth + parenWidthLeft + childWidthLeft + parenWidthRight, _radicalRootHeight + EDExpressionRadicalPowerOffsetVertical)];
                    }
                    
                    // set frame size
                    [self setFrameSize:NSMakeSize(_radicalRootWidth + parenWidthLeft + childWidthLeft + parenWidthRight + widthRadicalPower, largerHeight + _radicalRootHeight + EDExpressionRadicalPowerOffsetVertical)];
                }
                else{
                    // draw the base surrounded by parenthesis with the numerator exponent and a root symbol
                    float childWidthLeft=0, widthRadicalRoot=0, widthRadicalPower=0;
                    NSSize sizeRadicalRoot, sizeRadicalPower;
                    sizeRadicalRoot = [[[self childRight] childRight] frame].size;
                    sizeRadicalPower = [[[self childRight] childLeft] frame].size;
                    _radicalBaseWidth = 0;
                    _radicalBaseLeftParenWidth = 0;
                    
                    // radical root
                    EDExpressionNodeView *radicalRoot = [[self childRight] childRight];
                    // if radical root is 2, then don't show it
                    if ([[[radicalRoot token] tokenValue] isEqualToString:@"2"]){
                    }
                    else{
                        [self addSubview:radicalRoot];
                        [_addedSubviewsOtherThanRightAndLeftChildren addObject:radicalRoot];
                        widthRadicalRoot = sizeRadicalRoot.width;
                        _radicalBaseWidth += widthRadicalRoot;
                        _radicalRootHeight = sizeRadicalRoot.height-EDExpressionRadicalRootLowerLeftOriginOffset;
                    }
                    
                    // this is where the radical sign and the rest of the elements start drawing, so give it a bit of a buffer/offset
                    _radicalRootWidth = sizeRadicalRoot.width+EDExpressionRadicalRootUpperLeftOriginOffset;
                    [radicalRoot setFrameOrigin:NSMakePoint(0, 0)];
                    
                    // radical base
                    [self addSubview:childLeft];
                    childWidthLeft = [childLeft frame].size.width;
                    _radicalBaseWidth += childWidthLeft;
#warning this doesn't display correctly if the power of the base is a fraction or negative
                    [childLeft setFrameOrigin:NSMakePoint(_radicalRootWidth, _radicalRootHeight+5)];
                    
                    // radical power
                    EDExpressionNodeView *radicalPower = [[self childRight] childLeft];
                    // if radical power is 1, then don't show it
                    if ([[[radicalPower token] tokenValue] isEqualToString:@"1"]){
                    }
                    else{
                        [self addSubview:radicalPower];
                        [_addedSubviewsOtherThanRightAndLeftChildren addObject:radicalPower];
                        widthRadicalPower = sizeRadicalPower.width;
                        _radicalBaseWidth += widthRadicalPower;
                        _radicalPowerHeight = sizeRadicalPower.height;
                        [radicalPower setFrameOrigin:NSMakePoint(_radicalRootWidth + childWidthLeft , _radicalRootHeight+EDExpressionRadicalPowerOffsetVertical)];
                    }
                    
                    // set frame size
                    [self setFrameSize:NSMakeSize(_radicalRootWidth  + _radicalBaseWidth, largerHeight + _radicalRootHeight + EDExpressionRadicalPowerOffsetVertical)];
                }
            }
            else if ([[[self childLeft] token] typeRaw] == EDTokenTypeOperator){
                // draw the base surrounded by parenthesis with the numerator exponent and a root symbol
                float parenWidthLeft, parenWidthRight, childWidthLeft, childWidthRight, fontSize;
                NSSize sizeParenLeft, sizeParenRight, sizeChildLeft, sizeChildRight;
            
                sizeChildLeft = [[self childLeft] frame].size;
                sizeChildRight = [[self childRight] frame].size;
                
                // determine font size if it's a divide operation
                if ([[[[self childLeft] token] tokenValue] isEqualToString:@"/"])
                    fontSize = [EDExpressionNodeView fontSizeForString:@"(" height:[[self childLeft] frame].size.height];
                else
                    fontSize = [self fontSize]*[[self childLeft] fontModifier];
                
                // left paren
                sizeParenLeft = [EDExpressionNodeView getStringSize:@"(" fontSize:fontSize];
                NSTextField *fieldLeftParen = [EDExpressionNodeView generateTextField:fontSize string:@"("];
                [self addSubview:fieldLeftParen];
                [fieldLeftParen setFrameOrigin:NSMakePoint(0, sizeChildRight.height - EDExpressionExponentPowerBaseOffsetVertical)];
                [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldLeftParen];
                parenWidthLeft = [fieldLeftParen frame].size.width;
            
                // left child
                [self addSubview:childLeft];
                childWidthLeft = [childLeft frame].size.width;
                [childLeft setFrameOrigin:NSMakePoint(parenWidthLeft, sizeChildRight.height - EDExpressionExponentPowerBaseOffsetVertical)];
                
                // add right paren
                sizeParenRight = [EDExpressionNodeView getStringSize:@")" fontSize:fontSize];
                NSTextField *fieldRightParen = [EDExpressionNodeView generateTextField:fontSize string:@")"];
                [self addSubview:fieldRightParen];
                [fieldRightParen setFrameOrigin:NSMakePoint(parenWidthLeft + childWidthLeft, sizeChildRight.height - EDExpressionExponentPowerBaseOffsetVertical)];
                [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldRightParen];
                parenWidthRight = [fieldRightParen frame].size.width;
            
                // right child
                [self addSubview:[self childRight]];
                [childRight setFrameOrigin:NSMakePoint(parenWidthLeft + childWidthLeft + parenWidthRight, 0)];
                childWidthRight = [[self childRight] frame].size.width;
            
                // set frame size
                [self setFrameSize:NSMakeSize(parenWidthLeft + childWidthLeft + parenWidthRight + childWidthRight, sizeChildRight.height - EDExpressionExponentPowerBaseOffsetVertical + sizeChildLeft.height)];
            }
            else {
                // draw the base with the exponent
                float  childWidthLeft, childWidthRight;
                NSSize sizeChildLeft, sizeChildRight;
            
                sizeChildLeft = [[self childLeft] frame].size;
                sizeChildRight = [[self childRight] frame].size;
                
                // left child
                [self addSubview:childLeft];
                childWidthLeft = [childLeft frame].size.width;
                [childLeft setFrameOrigin:NSMakePoint(0, sizeChildRight.height-EDExpressionExponentPowerBaseOffsetVertical)];
                
                // right child
                [self addSubview:[self childRight]];
                [childRight setFrameOrigin:NSMakePoint(childWidthLeft, 0)];
                childWidthRight = [[self childRight] frame].size.width;
            
                // set frame size
                [self setFrameSize:NSMakeSize(childWidthLeft + childWidthRight, sizeChildRight.height - EDExpressionExponentPowerBaseOffsetVertical + sizeChildLeft.height)];
            }
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
        [[self childLeft] removeFromSuperview];
    }
    
    // remove any other subviews
    for (NSView *view in _addedSubviewsOtherThanRightAndLeftChildren){
        [view removeFromSuperview];
    }
    
    // empty views
    [_addedSubviewsOtherThanRightAndLeftChildren removeAllObjects];
}

@end