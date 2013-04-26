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
- (void)setVerticalPositions:(NSMutableArray *)textfields multiplyFields:(NSMutableArray *)multiplyFields fontSize:(float)fontSize;
- (NSTextField *)textfields:(NSMutableArray *)textfields largerThanHeight:(float)height;
- (void)adjustTextFields:(NSMutableArray *)textfields multiplyFields:(NSMutableArray *)multiplyFields baseline:(float)currentBaseline totalHeight:(float)height fontSize:(float)fontSize;
- (BOOL)hasOneNumberChildAndOneIdentifierChild;
- (BOOL)hasTwoNumberChildren;
@end

@implementation EDExpressionNodeView

@synthesize baseline, treeHeight, token, childLeft, childRight, parent;


- (id)initWithFrame:(NSRect)frameRect token:(EDToken *)newToken expression:(EDExpression *)expression{
    self = [super initWithFrame:frameRect];
    if (self) {
        [self setBaseline:nil];
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

#pragma mark node helpers
- (BOOL)hasOneNumberChildAndOneIdentifierChild{
    if ((([[[self childLeft] token] typeRaw] == EDTokenTypeIdentifier) && ([[[self childRight] token] typeRaw] == EDTokenTypeNumber)) ||
        (([[[self childLeft] token] typeRaw] == EDTokenTypeNumber) && ([[[self childRight] token] typeRaw] == EDTokenTypeIdentifier))){
            return TRUE;
    }
    return FALSE;
}

- (BOOL)hasTwoNumberChildren{
    if (([[[self childLeft] token] typeRaw] == EDTokenTypeNumber) && ([[[self childRight] token] typeRaw] == EDTokenTypeNumber))
            return TRUE;
        
    return FALSE;
}

#pragma mark generators
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
    //[returnField setDrawsBackground:TRUE];
    //[returnField setBackgroundColor:[NSColor blueColor]];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    [returnField setFont:[NSFont fontWithName:EDExpressionDefaultFontName size:fontSize]];
    [returnField setAttributedStringValue:attributedString];
    return returnField;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // size
    NSSize sizeChildLeft = [[self childLeft] frame].size, sizeChildRight = [[self childRight] frame].size;
    float largerWidth = MAX(sizeChildLeft.width, sizeChildRight.width);
    
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

#pragma mark adjust position
- (NSTextField *)textfields:(NSMutableArray *)textfields largerThanHeight:(float)height{
    float largestHeight = -1;
    NSTextField *returnField;
    for (NSTextField *textfield in textfields){
        if (([textfield frame].size.height>height) && ([textfield frame].size.height>largestHeight)){
            returnField = textfield;
            largestHeight = [textfield frame].size.height;
        }
    }
    return returnField;
}

- (void)adjustTextFields:(NSMutableArray *)textfields multiplyFields:(NSMutableArray *)multiplyFields baseline:(float)currentBaseline totalHeight:(float)height fontSize:(float)fontSize{
    for (NSTextField *textfield in textfields){
        if ([textfield frame].size.height == height)
            [textfield setFrameOrigin:NSMakePoint([textfield frame].origin.x, 0)];
        else
            [textfield setFrameOrigin:NSMakePoint([textfield frame].origin.x, currentBaseline - [textfield frame].size.height)];
        
        // adjust individual characters
        if (([[[textfield attributedStringValue] string] isEqualToString:@"("]) || ([[[textfield attributedStringValue] string] isEqualToString:@")"]))
            [textfield setFrameOrigin:NSMakePoint([textfield frame].origin.x, [textfield frame].origin.y + [[textfield font] pointSize] * -.1)];
        
        if (([[[textfield attributedStringValue] string] isEqualToString:@"+"]) || ([[[textfield attributedStringValue] string] isEqualToString:@"-"]))
            [textfield setFrameOrigin:NSMakePoint([textfield frame].origin.x, [textfield frame].origin.y + [[textfield font] pointSize] * EDExpressionAddSubtractVerticalModifier)];
    }
    
    for (NSTextField *multiplyField in multiplyFields){
        // adjust each character based on baseline
        [multiplyField setFrameOrigin:NSMakePoint([multiplyField frame].origin.x, currentBaseline - [multiplyField frame].size.height - fontSize * EDExpressionMultiplierModifierVertical)];
    }
}

- (void)setVerticalPositions:(NSMutableArray *)textfields multiplyFields:(NSMutableArray *)multiplyFields fontSize:(float)fontSize{
    //NSSize size = [EDExpressionNodeView getStringSize:@"x" fontSize:fontSize];
    NSTextField *fieldOperator = [EDExpressionNodeView generateTextField:fontSize string:@"x"];
    
    //NSLog(@"setVerticalPosition: setting baseline for token:%@ left child:%@ baseline:%f right child:%@ baseline:%f", [token tokenValue], [[childLeft token] tokenValue], [[childLeft baseline] floatValue], [[childRight token] tokenValue], [[childRight baseline] floatValue]);
    // check for division to determine position
    if (([[self token] typeRaw] == EDTokenTypeIdentifier) || ([[self token] typeRaw] == EDTokenTypeNumber)){
        // if a number or identifier then do nothing
    }
    else if ([[[self token] tokenValue] isEqualToString:@"/"]){
        // this is a division token
        EDExpressionNodeView *nodeNumerator, *nodeDenominator;
        nodeNumerator = [self childLeft];
        nodeDenominator = [self childRight];
        
        //NSLog(@"division: setting baseline for token:%@", [token tokenValue]);
        [self setBaseline:[NSNumber numberWithFloat:[nodeNumerator frame].size.height + EDExpressionXHeightRatio*[fieldOperator frame].size.height]];
        //NSLog(@"division: baseline:%@", [self baseline]);
        [self adjustTextFields:textfields multiplyFields:multiplyFields baseline:[[self baseline] floatValue] totalHeight:[self frame].size.height fontSize:fontSize];
    }
    else if ([[[self token] tokenValue] isEqualToString:@"^"]){
        EDExpressionNodeView *nodeExponent, *nodeBase;
        nodeExponent = [self childRight];
        nodeBase = [self childLeft];
        
        // need to set the baseline to the left child
        if ([nodeBase baseline] != nil) 
            [self setBaseline:[NSNumber numberWithFloat:[nodeExponent frame].size.height + [[nodeBase baseline] floatValue] + EDExpressionExponentPowerExponentModifierVertical*[self fontModifier]*[self fontSize]]];
        else
            [self setBaseline:[NSNumber numberWithFloat:[nodeExponent frame].size.height + [nodeBase frame].size.height + EDExpressionExponentPowerExponentModifierVertical*[self fontModifier]*[self fontSize]]];
    }
    else if (([[self childLeft] baseline] != nil) && ([[self childRight] baseline] != nil)){
        // both children have baselines
        EDExpressionNodeView *nodeLarger, *nodeSmaller;
        if ([[[self childLeft] baseline] floatValue] > [[[self childRight] baseline] floatValue]){
            nodeLarger = [self childLeft];
            nodeSmaller = [self childRight];
        }
        else{
            nodeSmaller = [self childLeft];
            nodeLarger = [self childRight];
        }
        
        // modify positions so baselines match
        [nodeLarger setFrameOrigin:NSMakePoint([nodeLarger frame].origin.x, 0)];
        [nodeSmaller setFrameOrigin:NSMakePoint([nodeSmaller frame].origin.x, [[nodeLarger baseline] floatValue] - [[nodeSmaller baseline] floatValue])];
        [self setBaseline:[NSNumber numberWithFloat:[[nodeLarger baseline] floatValue]]];
        [self adjustTextFields:textfields multiplyFields:multiplyFields baseline:[[nodeLarger baseline] floatValue] totalHeight:[self frame].size.height fontSize:fontSize];
    }
    else if (([[self childLeft] baseline] != nil) || ([[self childRight] baseline] != nil)){
        EDExpressionNodeView *nodeBaseline, *nodeNil;
        if ([[self childLeft] baseline] != nil){
            nodeBaseline = [self childLeft];
            nodeNil = [self childRight];
        }
        else{
            nodeNil = [self childLeft];
            nodeBaseline = [self childRight];
        }
        
        // find largest value other than baseline
        NSTextField *largerTextField = [self textfields:textfields largerThanHeight:[[nodeBaseline baseline] floatValue]];
        float newBaseline;
        if ([nodeNil frame].size.height > [[nodeBaseline baseline] floatValue]){
            // node nil is larger than baseline
            newBaseline = [nodeNil frame].size.height;
            [nodeNil setFrameOrigin:NSMakePoint([nodeNil frame].origin.x, 0)];
            [nodeBaseline setFrameOrigin:NSMakePoint([nodeBaseline frame].origin.x, [nodeNil frame].size.height - [[nodeBaseline baseline] floatValue])];
            
            [self setBaseline:[NSNumber numberWithFloat:newBaseline]];
            [self setFrameSize:NSMakeSize([self frame].size.width, [nodeNil frame].size.height+[nodeBaseline frame].size.height-[[nodeBaseline baseline] floatValue])];
            [self adjustTextFields:textfields multiplyFields:multiplyFields baseline:newBaseline totalHeight:[self frame].size.height fontSize:fontSize];
        }
        else if (largerTextField == nil){
            // the baseline node is the tallest element in the expression
            newBaseline = [[nodeBaseline baseline] floatValue];
            [nodeBaseline setFrameOrigin:NSMakePoint([nodeBaseline frame].origin.x, 0)];
            [nodeNil setFrameOrigin:NSMakePoint([nodeNil frame].origin.x, [[nodeBaseline baseline] floatValue]-[nodeNil frame].size.height)];
            
            [self setBaseline:[NSNumber numberWithFloat:newBaseline]];
            [self setFrameSize:NSMakeSize([self frame].size.width, [nodeBaseline frame].size.height)];
            [self adjustTextFields:textfields multiplyFields:multiplyFields baseline:newBaseline totalHeight:[self frame].size.height fontSize:fontSize];
        }
        else{
            // one of the text fields (i.e. parenthesis token) is taller than the other nodes
            float nodeOffsetBaseline = ([largerTextField frame].size.height-[nodeBaseline frame].size.height)/2;
            float nodeOffsetNil = nodeOffsetBaseline+[[nodeBaseline baseline] floatValue]-[nodeNil frame].size.height;
            newBaseline = nodeOffsetBaseline+[[nodeBaseline baseline] floatValue];
            [nodeNil setFrameOrigin:NSMakePoint([nodeNil frame].origin.x, nodeOffsetNil)];
            [nodeBaseline setFrameOrigin:NSMakePoint([nodeBaseline frame].origin.x, nodeOffsetBaseline)];
            
            [self setBaseline:[NSNumber numberWithFloat:newBaseline]];
            [self setFrameSize:NSMakeSize([self frame].size.width, [largerTextField frame].size.height)];
            [self adjustTextFields:textfields multiplyFields:multiplyFields baseline:newBaseline totalHeight:[largerTextField frame].size.height fontSize:fontSize];
        }
    }
}

- (void)traverseTreeAndCreateImage{
    NSMutableArray *otherFields = [NSMutableArray array];
    NSMutableArray *multiplyFields = [NSMutableArray array];
    
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
        
        [self setFrameSize:NSMakeSize([field frame].size.width, [field frame].size.height)];
        [self setVerticalPositions:nil multiplyFields:nil fontSize:[self fontModifier]*[self fontSize]];
    }
    else if ([[self token] typeRaw] == EDTokenTypeOperator){
        // size
        NSSize sizeChildLeft = [[self childLeft] frame].size, sizeChildRight = [[self childRight] frame].size;
        
        // height and width
        float largerHeight = MAX(sizeChildLeft.height, sizeChildRight.height);
        float largerWidth = MAX(sizeChildLeft.width, sizeChildRight.width);
        if (([[[self token] tokenValue] isEqualToString:@"+"]) || ([[[self token] tokenValue] isEqualToString:@"-"])){
            // add addition/subtraction oeprator
            float fontSize = [self fontModifier] * [self fontSize];
            NSSize sizeOperator = [EDExpressionNodeView getStringSize:@"x" fontSize:fontSize];
            
            // modify width of + and - sign
            sizeOperator = NSMakeSize(sizeOperator.width + fontSize * EDExpressionAddSubtractHorizontalModifier, sizeOperator.height);
            NSTextField *fieldOperator = [EDExpressionNodeView generateTextField:fontSize string:[[self token] tokenValue]];
            [self addSubview:fieldOperator];
            [fieldOperator setFrameOrigin:NSMakePoint(sizeChildLeft.width + fontSize * EDExpressionAddSubtractHorizontalModifier, largerHeight - sizeOperator.height)];
            [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldOperator];
            [otherFields addObject:fieldOperator];
            
            // left child
            [self addSubview:[self childLeft]];
            [[self childLeft] setFrameOrigin:NSMakePoint(0, largerHeight-sizeChildLeft.height)];
        
            // right child
            [self addSubview:[self childRight]];
            [[self childRight] setFrameOrigin:NSMakePoint(sizeChildLeft.width + sizeOperator.width + fontSize * EDExpressionAddSubtractHorizontalModifier, largerHeight-sizeChildRight.height)];
            [self setFrameSize:NSMakeSize(sizeChildLeft.width + fontSize * EDExpressionAddSubtractHorizontalModifier + sizeOperator.width + sizeChildRight.width, largerHeight)];
            [self setVerticalPositions:otherFields multiplyFields:nil fontSize:fontSize];
        }
        else if([[[self token] tokenValue] isEqualToString:@"/"]){
            float height = sizeChildLeft.height + EDExpressionDivisionGapVertical + EDExpressionDivisionLineWidth + EDExpressionDivisionGapVertical + sizeChildRight.height;
            [self addSubview:[self childLeft]];
            
            // center left child
            if (sizeChildLeft.width > sizeChildRight.width)
                [[self childLeft] setFrameOrigin:NSMakePoint(0, 0)];
            else{
                [[self childLeft] setFrameOrigin:NSMakePoint((largerWidth-sizeChildLeft.width)/2, 0)];
            }
            
            //right child
            [self addSubview:[self childRight]];
            
            // center left child
            if (sizeChildRight.width > sizeChildLeft.width)
                [[self childRight] setFrameOrigin:NSMakePoint(0, EDExpressionDivisionGapVertical+EDExpressionDivisionLineWidth+EDExpressionDivisionGapVertical+sizeChildLeft.height)];
            else{
                [[self childRight] setFrameOrigin:NSMakePoint((largerWidth-sizeChildRight.width)/2, EDExpressionDivisionGapVertical+EDExpressionDivisionLineWidth+EDExpressionDivisionGapVertical+sizeChildLeft.height)];
            }
            
            // reset frame size
            [self setFrameSize:NSMakeSize(largerWidth, height)];
            [self setVerticalPositions:otherFields multiplyFields:multiplyFields fontSize:[self fontSize] *[self fontModifier]];
            //NSLog(@"divide op: height left:%f self:%f right:%f", [[self childLeft] frame].size.height, 4.0, [[self childRight] frame].size.height);
            //NSLog(@"divide op: setting height to:%f right token:%@", height, [[[self childRight] token] tokenValue]);
        }
        else if([[[self token] tokenValue] isEqualToString:@"*"]){
            if (([[[self childLeft] token] typeRaw] == EDTokenTypeOperator) && ([[[self childRight] token] typeRaw] == EDTokenTypeOperator)){
                if (([[[childLeft token] tokenValue] isEqualToString:@"^"]) && ([[[childRight token] tokenValue] isEqualToString:@"^"])){
                    // if both of the operators are exponents then muliply them together with a multiply symbol
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
                    [otherFields addObject:fieldMultiply];
                    [multiplyFields addObject:fieldMultiply];
                    
                    // right child
                    [self addSubview:[self childRight]];
                    [[self childRight] setFrameOrigin:NSMakePoint(childWidthLeft + sizeOperator.width, 0)];
                    childWidthRight = [[self childRight] frame].size.width;
                    
                    [self setFrameSize:NSMakeSize(childWidthLeft + sizeOperator.width + childWidthRight, largerHeight)];
                    [self setVerticalPositions:otherFields multiplyFields:multiplyFields fontSize:[self fontSize]*[self fontModifier]];
                }
                else if (([[[childLeft token] tokenValue] isEqualToString:@"^"]) || ([[[childRight token] tokenValue] isEqualToString:@"^"])){
                    // one of the operators is an exponent so put that child on the left side and place the other operator on the right with parenthesis
                    EDExpressionNodeView *nodeExponent, *nodeOther;
                    float fontSize;
                    NSSize sizeParenLeft, sizeParenRight;
                    
                    // find exponent operator
                    if ([[[[self childLeft] token] tokenValue] isEqualToString:@"^"]){
                        nodeExponent = [self childLeft];
                        nodeOther = [self childRight];
                    }
                    else{
                        nodeExponent = [self childRight];
                        nodeOther = [self childLeft];
                    }
                    
                    // determine font size if it's a divide operation
                    if ([[[nodeOther token] tokenValue] isEqualToString:@"/"])
                        fontSize = [EDExpressionNodeView fontSizeForString:@"(" height:[[self childLeft] frame].size.height];
                    else
                        fontSize = [[self expression] fontSize]*[[self childLeft] fontModifier];
                    
                    // add exponent
                    [self addSubview:nodeExponent];
                    [nodeExponent setFrameOrigin:NSMakePoint(0, largerHeight - [nodeExponent frame].size.height)];
                    
                    // add left paren
                    sizeParenLeft = [EDExpressionNodeView getStringSize:@"(" fontSize:fontSize];
                    NSTextField *fieldLeftParen = [EDExpressionNodeView generateTextField:fontSize string:@"("];
                    [self addSubview:fieldLeftParen];
                    [fieldLeftParen setFrameOrigin:NSMakePoint([nodeExponent frame].size.width, largerHeight-sizeParenLeft.height)];
                    [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldLeftParen];
                    [otherFields addObject:fieldLeftParen];
                    
                    // other node
                    [self addSubview:nodeOther];
                    [nodeOther setFrameOrigin:NSMakePoint([nodeExponent frame].size.width + sizeParenLeft.width, largerHeight-[nodeOther frame].size.height)];
                    
                    // add right paren
                    sizeParenRight = [EDExpressionNodeView getStringSize:@")" fontSize:fontSize];
                    NSTextField *fieldRightParen = [EDExpressionNodeView generateTextField:fontSize string:@")"];
                    [self addSubview:fieldRightParen];
                    [fieldRightParen setFrameOrigin:NSMakePoint([nodeExponent frame].size.width + sizeParenLeft.width + [nodeOther frame].size.width, largerHeight-sizeParenRight.height)];
                    [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldRightParen];
                    [otherFields addObject:fieldRightParen];
                    
                    [self setFrameSize:NSMakeSize([nodeExponent frame].size.width + sizeParenLeft.width + [nodeOther frame].size.width + sizeParenRight.width, largerHeight)];
                    [self setVerticalPositions:otherFields multiplyFields:nil fontSize:fontSize];
                }
                /*
                else if ((([[[childLeft token] tokenValue] isEqualToString:@"*"]) && ([childLeft hasOneNumberChildAndOneIdentifierChild])) ||
                            (([[[childRight token] tokenValue] isEqualToString:@"*"]) && ([childRight hasOneNumberChildAndOneIdentifierChild])) ||
                            (([[[childLeft token] tokenValue] isEqualToString:@"*"]) && ([childLeft hasTwoNumberChildren])) ||
                            (([[[childRight token] tokenValue] isEqualToString:@"*"]) && ([childRight hasTwoNumberChildren]))){
                    // an identifier with a numerical coefficient on the left side and a factor on the right side
                    EDExpressionNodeView *nodeCoefficient, *nodeOther;
                    float fontSize;
                    NSSize sizeParenLeft, sizeParenRight;
                    
                    // find coefficient child
                    if (([childLeft hasTwoNumberChildren]) || ([childLeft hasOneNumberChildAndOneIdentifierChild])){
                        nodeCoefficient = [self childLeft];
                        nodeOther = [self childRight];
                    }
                    else{
                        nodeCoefficient = [self childRight];
                        nodeOther = [self childLeft];
                    }
                    
                    // determine font size if it's a divide operation
                    if ([[[nodeOther token] tokenValue] isEqualToString:@"/"])
                        fontSize = [EDExpressionNodeView fontSizeForString:@"(" height:[[self childLeft] frame].size.height];
                    else
                        fontSize = [[self expression] fontSize]*[[self childLeft] fontModifier];
                    
                    // add exponent
                    [self addSubview:nodeCoefficient];
                    [nodeCoefficient setFrameOrigin:NSMakePoint(0, largerHeight - [nodeCoefficient frame].size.height)];
                    
                    // add left paren
                    sizeParenLeft = [EDExpressionNodeView getStringSize:@"(" fontSize:fontSize];
                    NSTextField *fieldLeftParen = [EDExpressionNodeView generateTextField:fontSize string:@"("];
                    [self addSubview:fieldLeftParen];
                    [fieldLeftParen setFrameOrigin:NSMakePoint([nodeCoefficient frame].size.width, largerHeight-sizeParenLeft.height)];
                    [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldLeftParen];
                    [otherFields addObject:fieldLeftParen];
                    
                    // other node
                    [self addSubview:nodeOther];
                    [nodeOther setFrameOrigin:NSMakePoint([nodeCoefficient frame].size.width + sizeParenLeft.width, largerHeight-[nodeOther frame].size.height)];
                    
                    // add right paren
                    sizeParenRight = [EDExpressionNodeView getStringSize:@")" fontSize:fontSize];
                    NSTextField *fieldRightParen = [EDExpressionNodeView generateTextField:fontSize string:@")"];
                    [self addSubview:fieldRightParen];
                    [fieldRightParen setFrameOrigin:NSMakePoint([nodeCoefficient frame].size.width + sizeParenLeft.width + [nodeOther frame].size.width, largerHeight-sizeParenRight.height)];
                    [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldRightParen];
                    [otherFields addObject:fieldRightParen];
                    
                    [self setFrameSize:NSMakeSize([nodeCoefficient frame].size.width + sizeParenLeft.width + [nodeOther frame].size.width + sizeParenRight.width, largerHeight)];
                    [self setVerticalPositions:otherFields multiplyFields:nil fontSize:fontSize];
                }*/
                else{
                    // two operators, need to surround right and left child with parenthesis
                    float parenWidthLeft, parenWidthRight, childWidthLeft, childWidthRight, fontSize;
                    NSSize sizeParenLeft, sizeParenRight;
                    NSLog(@"two operators: left:%@", [[childLeft token] tokenValue]);
                    // determine font size if it's a divide operation
                    if ([[[[self childLeft] token] tokenValue] isEqualToString:@"/"])
                        fontSize = [EDExpressionNodeView fontSizeForString:@"(" height:[[self childLeft] frame].size.height];
                    else
                        fontSize = [[self expression] fontSize]*[[self childLeft] fontModifier];
                        
                    // add left paren
                    sizeParenLeft = [EDExpressionNodeView getStringSize:@"(" fontSize:fontSize];
                    NSTextField *fieldLeftParen = [EDExpressionNodeView generateTextField:fontSize string:@"("];
                    [self addSubview:fieldLeftParen];
                    [fieldLeftParen setFrameOrigin:NSMakePoint(0, largerHeight-sizeChildLeft.height)];
                    [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldLeftParen];
                    parenWidthLeft = [fieldLeftParen frame].size.width;
                    [otherFields addObject:fieldLeftParen];
                    
                    // left child
                    [self addSubview:[self childLeft]];
                    [[self childLeft] setFrameOrigin:NSMakePoint(parenWidthLeft, largerHeight-sizeChildLeft.height)];
                    childWidthLeft = [[self childLeft] frame].size.width;
                    
                    // add right paren
                    sizeParenRight = [EDExpressionNodeView getStringSize:@")" fontSize:fontSize];
                    NSTextField *fieldRightParen = [EDExpressionNodeView generateTextField:fontSize string:@")"];
                    [self addSubview:fieldRightParen];
                    [fieldRightParen setFrameOrigin:NSMakePoint(parenWidthLeft + childWidthLeft, largerHeight-sizeChildLeft.height)];
                    [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldRightParen];
                    [otherFields addObject:fieldRightParen];
                    NSLog(@"setting first right parent to origin y:%f largerHeight:%f size child left:%f child right:%f", [fieldRightParen frame].origin.y, largerHeight, sizeChildLeft.height, sizeChildRight.height);
                    
                    // determine font size if it's a divide operation
                    if ([[[[self childRight] token] tokenValue] isEqualToString:@"/"])
                        fontSize = [EDExpressionNodeView fontSizeForString:@"(" height:[[self childRight] frame].size.height];
                    else
                        fontSize = [[self expression] fontSize]*[[self childRight] fontModifier];
                        
                    // add left paren
                    sizeParenLeft = [EDExpressionNodeView getStringSize:@"(" fontSize:fontSize];
                    NSTextField *fieldSecondLeftParen = [EDExpressionNodeView generateTextField:fontSize string:@"("];
                    [self addSubview:fieldSecondLeftParen];
                    [fieldSecondLeftParen setFrameOrigin:NSMakePoint(parenWidthLeft + childWidthLeft + parenWidthLeft, largerHeight-sizeChildRight.height)];
                    [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldSecondLeftParen];
                    parenWidthRight = [fieldSecondLeftParen frame].size.width;
                    [otherFields addObject:fieldSecondLeftParen];
                    
                    // right child
                    [self addSubview:[self childRight]];
                    [[self childRight] setFrameOrigin:NSMakePoint(parenWidthLeft + childWidthLeft + parenWidthLeft + parenWidthRight, largerHeight-sizeChildRight.height)];
                    childWidthRight = [[self childRight] frame].size.width;
                    
                    // add second right paren
                    sizeParenRight = [EDExpressionNodeView getStringSize:@")" fontSize:fontSize];
                    NSTextField *fieldSecondRightParen = [EDExpressionNodeView generateTextField:fontSize string:@")"];
                    [self addSubview:fieldSecondRightParen];
                    [fieldSecondRightParen setFrameOrigin:NSMakePoint(parenWidthLeft + childWidthLeft + parenWidthLeft + parenWidthRight + childWidthRight, largerHeight-sizeChildRight.height)];
                    [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldSecondRightParen];
                    [otherFields addObject:fieldSecondRightParen];
                    
                    
                    [self setFrameSize:NSMakeSize(parenWidthLeft + childWidthLeft + parenWidthLeft + parenWidthRight + childWidthRight + parenWidthRight, largerHeight)];
                    [self setVerticalPositions:otherFields multiplyFields:nil fontSize:fontSize];
                }
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
                        [childOperator setFrameOrigin:NSMakePoint(0, largerHeight-heightOperator)];
                        childWidthLeft = [childOperator frame].size.width;
                        
                        // child identifier/number
                        [self addSubview:childIdentifierNumber];
                        [childIdentifierNumber setFrameOrigin:NSMakePoint(childWidthLeft, largerHeight-heightIdentifierNumber)];
                        childWidthRight = [childIdentifierNumber frame].size.width;
                        [self setFrameSize:NSMakeSize(childWidthLeft + childWidthRight, largerHeight)];
                        [self setVerticalPositions:nil multiplyFields:nil fontSize:[self fontSize]*[self fontModifier]];
                    }
                    else{
                        // left child operator
                        [self addSubview:childOperator];
                        [childOperator setFrameOrigin:NSMakePoint(0, largerHeight-heightOperator)];
                        childWidthLeft = [childOperator frame].size.width;
                        
                        // add multiply symbol
                        float fontSize = [self fontSize] * [self fontModifier] * EDExpressionSymbolMultiplicationSymbolFontModifier;
                        NSSize sizeOperator = [EDExpressionNodeView getStringSize:@"x" fontSize:fontSize];
                        NSTextField *fieldMultiply = [EDExpressionNodeView generateTextField:fontSize string:@"x"];
                        [self addSubview:fieldMultiply];
                        [fieldMultiply setFrameOrigin:NSMakePoint(childWidthLeft, largerHeight - sizeOperator.height)];
                        float widthOperator = [fieldMultiply frame].size.width;
                        [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldMultiply];
                        [otherFields addObject:fieldMultiply];
                        [multiplyFields addObject:fieldMultiply];
                            
                        // right child
                        [self addSubview:childIdentifierNumber];
                        [childIdentifierNumber setFrameOrigin:NSMakePoint(childWidthLeft + widthOperator, (largerHeight-heightIdentifierNumber)/2)];
                        childWidthRight = [childIdentifierNumber frame].size.width;
                        [self setFrameSize:NSMakeSize(childWidthLeft + widthOperator + childWidthRight, largerHeight)];
                        [self setVerticalPositions:otherFields multiplyFields:multiplyFields fontSize:[self fontSize]*[self fontModifier]];
                    }
                }
                else if ([[[childOperator token] tokenValue] isEqualToString:@"^"]){
                    // multiply an identifier/number with an exponent
                    NSSize sizeOperator = [childOperator frame].size;
                    NSSize sizeIdentifierNumber = [childIdentifierNumber frame].size;
                    float largerHeight = MAX(sizeOperator.height, sizeIdentifierNumber.height);
                    
                    // left child identifier/number
                    [self addSubview:childIdentifierNumber];
                    [childIdentifierNumber setFrameOrigin:NSMakePoint(0, largerHeight-sizeIdentifierNumber.height)];
                    
                    // right child
                    [self addSubview:childOperator];
                    [childOperator setFrameOrigin:NSMakePoint(sizeIdentifierNumber.width, largerHeight-sizeOperator.height)];
                    [self setFrameSize:NSMakeSize(sizeOperator.width + sizeIdentifierNumber.width, largerHeight)];
                    [self setVerticalPositions:nil multiplyFields:nil fontSize:[self fontSize]*[self fontModifier]];
                }
                else if ([[[childOperator token] tokenValue] isEqualToString:@"*"]){
                    // determine larger height
                    NSSize sizeOperator = [childOperator frame].size;
                    NSSize sizeIdentifierNumber = [childIdentifierNumber frame].size;
                    float largerHeight = MAX(sizeOperator.height, sizeIdentifierNumber.height);
                    
                    // just multiply tokens together
                    // left child operator
                    [self addSubview:childOperator];
                    [childOperator setFrameOrigin:NSMakePoint(0, largerHeight-sizeOperator.height)];
                                                          
                    // add multiply symbol
                    float fontSize = [self fontSize] * [self fontModifier] * EDExpressionSymbolMultiplicationSymbolFontModifier;
                    NSSize sizeMultiply = [EDExpressionNodeView getStringSize:@"x" fontSize:fontSize];
                    NSTextField *fieldMultiply = [EDExpressionNodeView generateTextField:fontSize string:@"x"];
                    [self addSubview:fieldMultiply];
                    [fieldMultiply setFrameOrigin:NSMakePoint(sizeChildLeft.width, 0)];
                    [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldMultiply];
                    [otherFields addObject:fieldMultiply];
                    [multiplyFields addObject:fieldMultiply];
                        
                    // right child
                    [self addSubview:childIdentifierNumber];
                    [childIdentifierNumber setFrameOrigin:NSMakePoint(sizeOperator.width + sizeMultiply.width, largerHeight-sizeIdentifierNumber.height)];
                    // set frame size
                    [self setFrameSize:NSMakeSize(sizeOperator.width + sizeMultiply.width + sizeIdentifierNumber.width, largerHeight)];
                    [self setVerticalPositions:otherFields multiplyFields:multiplyFields fontSize:[self fontSize]*[self fontModifier]];
                }
                else{
                    // determine larger height
                    float heightOperator = [childOperator frame].size.height;
                    float heightIdentifierNumber = [childIdentifierNumber frame].size.height;
                    float largerHeight = MAX(heightOperator, heightIdentifierNumber);
                    
                    // determine font size if it's a divide operation
                    /*
                    if ([[[childOperator token] tokenValue] isEqualToString:@"/"])
                        fontSize = [EDExpressionNodeView fontSizeForString:@"(" height:[childOperator frame].size.height];
                    else
                        fontSize = [[self expression] fontSize]*[childOperator fontModifier];
                     */
                    fontSize = [EDExpressionNodeView fontSizeForString:@"(" height:[childOperator frame].size.height];
                    
                    // figure out which child to surround with parenthesis
                    if ([[[self childRight] token] typeRaw] == EDTokenTypeOperator){
                        // right child is operator
                        // left child
                        [self addSubview:childLeft];
                        [childLeft setFrameOrigin:NSMakePoint(0, largerHeight-sizeChildLeft.height)];
                        
                        // add left paren
                        sizeParenLeft = [EDExpressionNodeView getStringSize:@"(" fontSize:fontSize];
                        NSTextField *fieldLeftParen = [EDExpressionNodeView generateTextField:fontSize string:@"("];
                        [self addSubview:fieldLeftParen];
                        [fieldLeftParen setFrameOrigin:NSMakePoint(sizeChildLeft.width, largerHeight-sizeParenLeft.height)];
                        [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldLeftParen];
                        [otherFields addObject:fieldLeftParen];
                        parenWidthLeft = [fieldLeftParen frame].size.width;
                        
                        // right child
                        [self addSubview:childRight];
                        [childRight setFrameOrigin:NSMakePoint(sizeChildLeft.width + parenWidthLeft, largerHeight-sizeChildRight.height)];
                        
                        // add right paren
                        sizeParenRight = [EDExpressionNodeView getStringSize:@")" fontSize:fontSize];
                        NSTextField *fieldRightParen = [EDExpressionNodeView generateTextField:fontSize string:@")"];
                        [self addSubview:fieldRightParen];
                        [fieldRightParen setFrameOrigin:NSMakePoint(sizeChildLeft.width + parenWidthLeft + sizeChildRight.width, largerHeight-sizeParenLeft.height)];
                        [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldRightParen];
                        [otherFields addObject:fieldRightParen];
                        parenWidthRight = [fieldRightParen frame].size.width;
                        
                        // adjustments
                        [self setFrameSize:NSMakeSize(sizeChildLeft.width + parenWidthLeft + sizeChildRight.width + parenWidthRight, largerHeight)];
                        [self setVerticalPositions:otherFields multiplyFields:nil fontSize:[self fontSize]*[self fontModifier]];
                    }
                    else{
                        // left child is the operator
                        // add left paren
                        sizeParenLeft = [EDExpressionNodeView getStringSize:@"(" fontSize:fontSize];
                        NSTextField *fieldLeftParen = [EDExpressionNodeView generateTextField:fontSize string:@"("];
                        [self addSubview:fieldLeftParen];
                        [fieldLeftParen setFrameOrigin:NSMakePoint(0, largerHeight-sizeParenLeft.height)];
                        [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldLeftParen];
                        [otherFields addObject:fieldLeftParen];
                        parenWidthLeft = [fieldLeftParen frame].size.width;
                        
                        // left child
                        [self addSubview:childLeft];
                        [childLeft setFrameOrigin:NSMakePoint(sizeParenLeft.width, largerHeight-sizeChildLeft.height)];
                        childWidthLeft = [childLeft frame].size.width;
                        
                        // add right paren
                        sizeParenRight = [EDExpressionNodeView getStringSize:@")" fontSize:fontSize];
                        NSTextField *fieldRightParen = [EDExpressionNodeView generateTextField:fontSize string:@")"];
                        [self addSubview:fieldRightParen];
                        [fieldRightParen setFrameOrigin:NSMakePoint(sizeParenLeft.width + childWidthLeft, largerHeight-sizeParenRight.height)];
                        [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldRightParen];
                        [otherFields addObject:fieldRightParen];
                        parenWidthRight = [fieldRightParen frame].size.width;
                        
                        // multiplication operator
                        NSSize sizeOperator = [EDExpressionNodeView getStringSize:@"x" fontSize:fontSize];
                        NSTextField *fieldMultiply = [EDExpressionNodeView generateTextField:fontSize string:@"x"];
                        [self addSubview:fieldMultiply];
                        [fieldMultiply setFrameOrigin:NSMakePoint(sizeParenLeft.width + childWidthLeft + sizeParenRight.width, 0)];
                        [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldMultiply];
                        [otherFields addObject:fieldMultiply];
                        [multiplyFields addObject:fieldMultiply];
                        
                        // right child operator
                        [self addSubview:childRight];
                        [childRight setFrameOrigin:NSMakePoint(sizeParenLeft.width + childWidthLeft + sizeParenRight.width + sizeOperator.width, largerHeight-sizeChildRight.height)];
                        childWidthRight = [childRight frame].size.width;
                        
                        // adjustments
                        [self setFrameSize:NSMakeSize(parenWidthLeft + childWidthLeft + parenWidthRight + sizeOperator.width + childWidthRight , largerHeight)];
                        [self setVerticalPositions:otherFields multiplyFields:multiplyFields fontSize:[self fontSize]*[self fontModifier]];
                    }
                }
            }
            /*
            else if ((([[[self childLeft] token] typeRaw] == EDTokenTypeNumber) && ([[[[self childLeft] token] tokenValue] isEqualToString:@"-1"]))&&
                     (([[[self childRight] token] typeRaw] == EDTokenTypeIdentifier) || ([[[self childRight] token] typeRaw] == EDTokenTypeNumber))){
                // a negative one token multiplied by an identifier/number
                // combine into a negative identifier/number
                
                // right child
                // show right child as negative
                NSTextField *newRightChild = [EDExpressionNodeView generateTextField:[self fontSize]*[self fontModifier] string:[NSString stringWithFormat:@"-%@", [[[self childRight] token] tokenValue]]];
                
                [self addSubview:newRightChild];
                [_addedSubviewsOtherThanRightAndLeftChildren addObject:newRightChild];
                
                [self setFrameSize:NSMakeSize([newRightChild frame].size.width, [newRightChild frame].size.height)];
                [self setVerticalPositions:nil multiplyFields:nil fontSize:[self fontSize]*[self fontModifier]];
            }
            else if ((([[[self childLeft] token] typeRaw] == EDTokenTypeNumber) && ([[[[self childLeft] token] tokenValue] isEqualToString:@"1"]))&&
                     (([[[self childRight] token] typeRaw] == EDTokenTypeIdentifier) || ([[[self childRight] token] typeRaw] == EDTokenTypeNumber))){
                // a positive one token multiplied by an identifier/number
                // combine into a positive identifier/number
                
                // right child
                // show right child as negative
                NSTextField *newRightChild = [EDExpressionNodeView generateTextField:[self fontSize]*[self fontModifier] string:[NSString stringWithFormat:@"%@", [[[self childRight] token] tokenValue]]];
                
                [self addSubview:newRightChild];
                [_addedSubviewsOtherThanRightAndLeftChildren addObject:newRightChild];
                
                [self setFrameSize:NSMakeSize([newRightChild frame].size.width, [newRightChild frame].size.height)];
                [self setVerticalPositions:nil multiplyFields:nil fontSize:[self fontSize]*[self fontModifier]];
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
                [otherFields addObject:fieldMultiply];
                [multiplyFields addObject:fieldMultiply];
                
                // right child
                [self addSubview:[self childRight]];
                [[self childRight] setFrameOrigin:NSMakePoint(childWidthLeft + sizeOperator.width, 0)];
                childWidthRight = [[self childRight] frame].size.width;
                
                [self setFrameSize:NSMakeSize(childWidthLeft + sizeOperator.width + childWidthRight, largerHeight)];
                [self setVerticalPositions:otherFields multiplyFields:multiplyFields fontSize:[self fontSize]*[self fontModifier]];
            }*/
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
                [self setVerticalPositions:nil multiplyFields:nil fontSize:[self fontSize]*[self fontModifier]];
            }
        }
        else if([[[self token] tokenValue] isEqualToString:@"^"]){
            if ([[[[self childRight] token] tokenValue] isEqualToString:@"/"]){
                if ([[[self childLeft] token] typeRaw] == EDTokenTypeOperator){
                    // for root symbols the baseline is not used and vertical positions are not adjusted
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
                    // for root symbols the baseline is not used and vertical positions are not adjusted
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
                // draw the base surrounded by parenthesis with the numerator exponent
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
                [fieldLeftParen setFrameOrigin:NSMakePoint(0, sizeChildRight.height + EDExpressionExponentPowerExponentModifierVertical*[self fontModifier]*[self fontSize])];
                [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldLeftParen];
                [otherFields addObject:fieldLeftParen];
                parenWidthLeft = [fieldLeftParen frame].size.width;
            
                // left child
                [self addSubview:childLeft];
                childWidthLeft = [childLeft frame].size.width;
                [childLeft setFrameOrigin:NSMakePoint(parenWidthLeft, sizeChildRight.height + EDExpressionExponentPowerExponentModifierVertical*[self fontModifier]*[self fontSize])];
                
                // add right paren
                sizeParenRight = [EDExpressionNodeView getStringSize:@")" fontSize:fontSize];
                NSTextField *fieldRightParen = [EDExpressionNodeView generateTextField:fontSize string:@")"];
                [self addSubview:fieldRightParen];
                [fieldRightParen setFrameOrigin:NSMakePoint(parenWidthLeft + childWidthLeft, sizeChildRight.height + EDExpressionExponentPowerExponentModifierVertical*[self fontModifier]*[self fontSize])];
                [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldRightParen];
                [otherFields addObject:fieldRightParen];
                parenWidthRight = [fieldRightParen frame].size.width;
            
                // right child
                [self addSubview:[self childRight]];
                [childRight setFrameOrigin:NSMakePoint(parenWidthLeft + childWidthLeft + parenWidthRight, 0)];
                childWidthRight = [[self childRight] frame].size.width;
            
                // set frame size
                [self setFrameSize:NSMakeSize(parenWidthLeft + childWidthLeft + parenWidthRight + childWidthRight, sizeChildRight.height + EDExpressionExponentPowerExponentModifierVertical*[self fontModifier]*[self fontSize] + sizeChildLeft.height)];
                [self setVerticalPositions:otherFields multiplyFields:nil fontSize:[self fontSize] *[self fontModifier]];
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
                [childLeft setFrameOrigin:NSMakePoint(0, sizeChildRight.height+EDExpressionExponentPowerExponentModifierVertical*[self fontModifier]*[self fontSize])];
                
                // right child
                [self addSubview:[self childRight]];
                [childRight setFrameOrigin:NSMakePoint(childWidthLeft, 0)];
                childWidthRight = [[self childRight] frame].size.width;
            
                // set frame size
                [self setFrameSize:NSMakeSize(childWidthLeft + childWidthRight, sizeChildRight.height + EDExpressionExponentPowerExponentModifierVertical*[self fontModifier]*[self fontSize] + sizeChildLeft.height)];
                [self setVerticalPositions:nil multiplyFields:nil fontSize:[self fontSize]*[self fontModifier]];
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