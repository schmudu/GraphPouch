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
- (NSDictionary *)addParenthesis:(NSString *)parenthesis largerHeight:(float)largerHeight sizeChild:(NSSize)sizeChild positionX:(float)positionX;
@end

@implementation EDExpressionNodeView

@synthesize baseline, treeHeight, token, childLeft, childRight, parent;


- (id)initWithFrame:(NSRect)frameRect token:(EDToken *)newToken expression:(EDExpression *)expression{
    self = [super initWithFrame:frameRect];
    if (self) {
        [self setBaseline:nil];
        _parenLeftWidth = 0;
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

- (NSDictionary *)addParenthesis:(NSString *)parenthesis largerHeight:(float)largerHeight sizeChild:(NSSize)sizeChild positionX:(float)positionX{
    //float fontSizeParenthesis = [EDExpressionNodeView fontSizeForString:parenthesis height:largerHeight];
    NSMutableDictionary *resultsDict = [NSMutableDictionary dictionary];
    NSTextField *fieldParen = [EDExpressionNodeView generateTextField:[self fontSize] string:parenthesis];
    [resultsDict setObject:[NSNumber numberWithFloat:[fieldParen frame].size.width] forKey:EDKeyParenthesisWidth];
    [self addSubview:fieldParen];
    [fieldParen setFrameOrigin:NSMakePoint(positionX, largerHeight-[fieldParen frame].size.height)];
    [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldParen];
    [resultsDict setObject:fieldParen forKey:EDKeyParenthesisTextField];
    return resultsDict;
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
            [path moveToPoint:NSMakePoint(_parenLeftWidth, [[self childLeft] frame].size.height + 1)];
            [path lineToPoint:NSMakePoint(_parenLeftWidth + largerWidth, [[self childLeft] frame].size.height + 1)];
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
    
    // only modify position if baseline is set
    //if (currentBaseline != 0){
        for (NSTextField *textfield in textfields){
            //NSLog(@"setting textfield:%@ baseline:%f height:%f final origin:%f", [[textfield attributedStringValue] string], currentBaseline, [textfield frame].size.height, currentBaseline - [textfield frame].size.height);
            [textfield setFrameOrigin:NSMakePoint([textfield frame].origin.x, currentBaseline - [textfield frame].size.height)];
            
            // adjust individual characters
            if (([[[textfield attributedStringValue] string] isEqualToString:@"+"]) || ([[[textfield attributedStringValue] string] isEqualToString:@"-"]))
                [textfield setFrameOrigin:NSMakePoint([textfield frame].origin.x, [textfield frame].origin.y + [[textfield font] pointSize] * EDExpressionAddSubtractVerticalModifier)];
        }
    //}
    
    for (NSTextField *multiplyField in multiplyFields){
        //NSLog(@"old origin:%f new origin for multiplier:%f multiply height:%f fontSize:%f current baseline:%f", [multiplyField frame].origin.y, currentBaseline - [multiplyField frame].size.height + fontSize * EDExpressionMultiplierModifierVertical, [multiplyField frame].size.height, fontSize, currentBaseline);
        // adjust each character based on baseline
        [multiplyField setFrameOrigin:NSMakePoint([multiplyField frame].origin.x, currentBaseline - [multiplyField frame].size.height + fontSize * EDExpressionMultiplierModifierVertical)];
    }
}

- (void)setVerticalPositions:(NSMutableArray *)textfields multiplyFields:(NSMutableArray *)multiplyFields fontSize:(float)fontSize{
    NSTextField *fieldOperator = [EDExpressionNodeView generateTextField:fontSize string:@"x"];
    
    // check for division to determine position
    if (([[self token] typeRaw] == EDTokenTypeIdentifier) || ([[self token] typeRaw] == EDTokenTypeNumber)){
        // if a number or identifier then do nothing
    }
    else if ([[[self token] tokenValue] isEqualToString:@"/"]){
        // this is a division token
        EDExpressionNodeView *nodeNumerator, *nodeDenominator;
        nodeNumerator = [self childLeft];
        nodeDenominator = [self childRight];
        
        [self setBaseline:[NSNumber numberWithFloat:[nodeNumerator frame].size.height + EDExpressionXHeightRatio*[fieldOperator frame].size.height]];
        [self adjustTextFields:textfields multiplyFields:multiplyFields baseline:[[self baseline] floatValue] totalHeight:[self frame].size.height fontSize:fontSize];
    }
    else if ([[[self token] tokenValue] isEqualToString:@"^"]){
        EDExpressionNodeView *nodeExponent, *nodeBase;
        nodeExponent = [self childRight];
        nodeBase = [self childLeft];
        
        // need to set the baseline to the left child
        if ([nodeBase baseline] != nil) 
            [self setBaseline:[NSNumber numberWithFloat:[nodeExponent frame].size.height + [[nodeBase baseline] floatValue] + EDExpressionExponentPowerExponentModifierVertical*[self fontModifier]*[self fontSize]]];
        else{
            [self setBaseline:[NSNumber numberWithFloat:[nodeExponent frame].size.height + [nodeBase frame].size.height + EDExpressionExponentPowerExponentModifierVertical*[self fontModifier]*[self fontSize]]];
        }
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
        //NSLog(@"baseline larger:%f smaller:%f", [[nodeLarger baseline] floatValue], [[nodeSmaller baseline] floatValue]);
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
        //float largerHeight = MAX([nodeNil frame].size.height, [[nodeBaseline baseline] floatValue]);
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
        //else if (largerTextField == nil){
        else{
            // the baseline node is the tallest element in the expression
            newBaseline = [[nodeBaseline baseline] floatValue];
            [nodeBaseline setFrameOrigin:NSMakePoint([nodeBaseline frame].origin.x, 0)];
            //[nodeNil setFrameOrigin:NSMakePoint([nodeNil frame].origin.x, ([[nodeBaseline baseline] floatValue]-[nodeNil frame].size.height)/2)];
            [nodeNil setFrameOrigin:NSMakePoint([nodeNil frame].origin.x, [[nodeBaseline baseline] floatValue]-[nodeNil frame].size.height)];
            //NSLog(@"baseline:%f nil height:%f nil origin:%f baseline origin:%f", newBaseline, [nodeNil frame].size.height, [nodeNil frame].origin.y, [nodeBaseline frame].origin.y);
            [self setBaseline:[NSNumber numberWithFloat:newBaseline]];
            [self setFrameSize:NSMakeSize([self frame].size.width, [nodeBaseline frame].size.height)];
            [self adjustTextFields:textfields multiplyFields:multiplyFields baseline:newBaseline totalHeight:[self frame].size.height fontSize:fontSize];
        }
    }
    /*
    else{
        //[self adjustTextFields:textfields multiplyFields:multiplyFields baseline:0 totalHeight:0 fontSize:fontSize];
    }*/
}

- (void)traverseTreeAndCreateImage{
    NSMutableArray *otherFields = [NSMutableArray array];
    NSMutableArray *multiplyFields = [NSMutableArray array];
    float currentTokenFontSize = [self fontSize] * [self fontModifier];
    
    // traverse right
    if([self childRight]) [[self childRight] traverseTreeAndCreateImage];
    
    // traverse left
    if([self childLeft]) [[self childLeft] traverseTreeAndCreateImage];
    
    // print out token
    //NSLog(@"traverse tree: token:%@ height:%d left token:%@ right token:%@", [token tokenValue], [self treeHeight], [[childLeft token] tokenValue], [[childRight token] tokenValue]);
    // create image
    if (([[self token] typeRaw] == EDTokenTypeNumber) || ([[self token] typeRaw] == EDTokenTypeIdentifier)){
        // every node view has a baseline, see x-height article on wikipedia.org for more info
        NSTextField *field = [EDExpressionNodeView generateTextField:currentTokenFontSize string:[token tokenValue]];
        [self addSubview:field];
        [self setFrameSize:NSMakeSize([field frame].size.width, [field frame].size.height)];
        [self setVerticalPositions:nil multiplyFields:nil fontSize:currentTokenFontSize];
    }
    else if ([[self token] typeRaw] == EDTokenTypeOperator){
        // sizes
        NSSize sizeChildLeft = [[self childLeft] frame].size, sizeChildRight = [[self childRight] frame].size;
        float largerHeight = MAX(sizeChildLeft.height, sizeChildRight.height);
        float largerWidth = MAX(sizeChildLeft.width, sizeChildRight.width);
        NSSize largerSize = NSMakeSize(largerWidth, largerHeight);
        
        if (([[[self token] tokenValue] isEqualToString:@"+"]) || ([[[self token] tokenValue] isEqualToString:@"-"])){
            // add addition/subtraction operator
            NSSize sizeOperator = [EDExpressionNodeView getStringSize:@"x" fontSize:currentTokenFontSize];
            
            // add parenthesis before operator, if it exists
            NSDictionary *parenDict;
            float parenWidth=0;
            for (int i=0; i<[[token parenthesisCount] intValue]; i++){
                parenDict = [self addParenthesis:@"(" largerHeight:largerHeight sizeChild:sizeChildLeft positionX:0];
                if ([parenDict objectForKey:EDKeyParenthesisTextField]){
                    [otherFields addObject:[parenDict objectForKey:EDKeyParenthesisTextField]];
                    parenWidth += [[parenDict objectForKey:EDKeyParenthesisWidth] floatValue];
                    _parenLeftWidth += parenWidth;
                }
            }
            
            // modify width of + and - sign
            sizeOperator = NSMakeSize(sizeOperator.width + currentTokenFontSize * EDExpressionAddSubtractHorizontalModifier, sizeOperator.height);
            NSTextField *fieldOperator = [EDExpressionNodeView generateTextField:currentTokenFontSize string:[[self token] tokenValue]];
            [self addSubview:fieldOperator];
            [fieldOperator setFrameOrigin:NSMakePoint(parenWidth + sizeChildLeft.width + currentTokenFontSize * EDExpressionAddSubtractHorizontalModifier, largerHeight - sizeOperator.height)];
            [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldOperator];
            [otherFields addObject:fieldOperator];
            
            // left child
            [self addSubview:[self childLeft]];
            [[self childLeft] setFrameOrigin:NSMakePoint(0 + parenWidth, largerHeight-sizeChildLeft.height)];
        
            // right child
            [self addSubview:[self childRight]];
            [[self childRight] setFrameOrigin:NSMakePoint(parenWidth + sizeChildLeft.width + sizeOperator.width + currentTokenFontSize * EDExpressionAddSubtractHorizontalModifier, largerHeight-sizeChildRight.height)];
            
            // add parenthesis after right child
            for (int i=0; i<[[token parenthesisCount] intValue]; i++){
                parenDict = [self addParenthesis:@")" largerHeight:largerHeight sizeChild:sizeChildLeft positionX:parenWidth + sizeChildLeft.width + sizeOperator.width + currentTokenFontSize * EDExpressionAddSubtractHorizontalModifier + sizeChildRight.width];
                if ([parenDict objectForKey:EDKeyParenthesisTextField]){
                    [otherFields addObject:[parenDict objectForKey:EDKeyParenthesisTextField]];
                    parenWidth += [[parenDict objectForKey:EDKeyParenthesisWidth] floatValue];
                }
            }
            
            [self setFrameSize:NSMakeSize(parenWidth + sizeChildLeft.width + currentTokenFontSize * EDExpressionAddSubtractHorizontalModifier + sizeOperator.width + sizeChildRight.width, largerHeight)];
            [self setVerticalPositions:otherFields multiplyFields:nil fontSize:currentTokenFontSize];
        }
        else if([[[self token] tokenValue] isEqualToString:@"/"]){
            float height = sizeChildLeft.height + EDExpressionDivisionGapVertical + EDExpressionDivisionLineWidth + EDExpressionDivisionGapVertical + sizeChildRight.height;
            [self addSubview:[self childLeft]];
            
            NSSize termSize = NSMakeSize(sizeChildLeft.width, height);
            
            // add left parenthesis
            NSDictionary *parenDict;
            float parenWidth=0;
            for (int i=0; i<[[token parenthesisCount] intValue]; i++){
                parenDict = [self addParenthesis:@"(" largerHeight:height sizeChild:termSize positionX:0];
                if ([parenDict objectForKey:EDKeyParenthesisTextField]){
                    [otherFields addObject:[parenDict objectForKey:EDKeyParenthesisTextField]];
                    parenWidth += [[parenDict objectForKey:EDKeyParenthesisWidth] floatValue];
                    _parenLeftWidth += parenWidth;
                }
            }
            
            // center left child
            if (sizeChildLeft.width > sizeChildRight.width)
                [[self childLeft] setFrameOrigin:NSMakePoint(parenWidth, 0)];
            else{
                [[self childLeft] setFrameOrigin:NSMakePoint(parenWidth + (largerWidth-sizeChildLeft.width)/2, 0)];
            }
            
            //right child
            [self addSubview:[self childRight]];
            
            // center left child
            if (sizeChildRight.width > sizeChildLeft.width)
                [[self childRight] setFrameOrigin:NSMakePoint(parenWidth, EDExpressionDivisionGapVertical+EDExpressionDivisionLineWidth+EDExpressionDivisionGapVertical+sizeChildLeft.height)];
            else{
                [[self childRight] setFrameOrigin:NSMakePoint(parenWidth + (largerWidth-sizeChildRight.width)/2, EDExpressionDivisionGapVertical+EDExpressionDivisionLineWidth+EDExpressionDivisionGapVertical+sizeChildLeft.height)];
            }
            
            // add parenthesis after right child
            for (int i=0; i<[[token parenthesisCount] intValue]; i++){
                parenDict = [self addParenthesis:@")" largerHeight:height sizeChild:termSize positionX:parenWidth + largerWidth];
                if ([parenDict objectForKey:EDKeyParenthesisTextField]){
                    [otherFields addObject:[parenDict objectForKey:EDKeyParenthesisTextField]];
                    parenWidth += [[parenDict objectForKey:EDKeyParenthesisWidth] floatValue];
                }
            }
            
            // reset frame size
            [self setFrameSize:NSMakeSize(parenWidth + largerWidth, height)];
            [self setVerticalPositions:otherFields multiplyFields:multiplyFields fontSize:currentTokenFontSize];
        }
        else if([[[self token] tokenValue] isEqualToString:@"*"]){
            if (([[[self childLeft] token] typeRaw] == EDTokenTypeOperator) && ([[[self childRight] token] typeRaw] == EDTokenTypeOperator)){
                if (([[[childLeft token] tokenValue] isEqualToString:@"^"]) && ([[[childRight token] tokenValue] isEqualToString:@"^"])){
                    // if both of the operators are exponents then muliply them together with a multiply symbol
                    float fontSizeMultiply = currentTokenFontSize * EDExpressionSymbolMultiplicationSymbolFontModifier;
                    NSSize sizeOperator;
                    
                    // add left parenthesis
                    NSDictionary *parenDict;
                    float parenWidth=0;
                    for (int i=0; i<[[[self token] parenthesisCount] intValue]; i++){
                        parenDict = [self addParenthesis:@"(" largerHeight:largerHeight sizeChild:sizeChildLeft positionX:0];
                        if ([parenDict objectForKey:EDKeyParenthesisTextField]){
                            [otherFields addObject:[parenDict objectForKey:EDKeyParenthesisTextField]];
                            parenWidth += [[parenDict objectForKey:EDKeyParenthesisWidth] floatValue];
                            _parenLeftWidth += parenWidth;
                        }
                    }
                
                    // left child
                    [self addSubview:[self childLeft]];
                    [[self childLeft] setFrameOrigin:NSMakePoint(parenWidth, 0)];
                    sizeChildLeft.width = [[self childLeft] frame].size.width;
                
                    if ([token isImplicit]){
                        // if implicit then don't add size
                        sizeOperator = NSMakeSize(0, 0);
                    }
                    else{
                        // add multiply symbol
                        NSTextField *fieldMultiply = [EDExpressionNodeView generateTextField:fontSizeMultiply string:@"∙"];
                        sizeOperator = [fieldMultiply frame].size;
                        [self addSubview:fieldMultiply];
                        [fieldMultiply setFrameOrigin:NSMakePoint(parenWidth + sizeChildLeft.width, 0)];
                        [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldMultiply];
                        [otherFields addObject:fieldMultiply];
                        [multiplyFields addObject:fieldMultiply];
                    }
                
                    // right child
                    [self addSubview:[self childRight]];
                    [[self childRight] setFrameOrigin:NSMakePoint(parenWidth + sizeChildLeft.width + sizeOperator.width, 0)];
                    sizeChildRight.width = [[self childRight] frame].size.width;
                    
                    // add parenthesis after right child
                    for (int i=0; i<[[[self token] parenthesisCount] intValue]; i++){
                        parenDict = [self addParenthesis:@")" largerHeight:largerHeight sizeChild:sizeChildLeft positionX:parenWidth + sizeChildLeft.width + sizeOperator.width + sizeChildRight.width];
                        if ([parenDict objectForKey:EDKeyParenthesisTextField]){
                            [otherFields addObject:[parenDict objectForKey:EDKeyParenthesisTextField]];
                            parenWidth += [[parenDict objectForKey:EDKeyParenthesisWidth] floatValue];
                        }
                    }
                    
                    [self setFrameSize:NSMakeSize(parenWidth + sizeChildLeft.width + sizeOperator.width + sizeChildRight.width, largerHeight)];
                    [self setVerticalPositions:otherFields multiplyFields:multiplyFields fontSize:currentTokenFontSize];
                }
                else{
                    // two operators, need to surround right and left child with parenthesis
                    // add left parenthesis
                    NSDictionary *parenDict;
                    float parenWidth=0;
                    for (int i=0; i<[[[self token] parenthesisCount] intValue]; i++){
                        parenDict = [self addParenthesis:@"(" largerHeight:largerHeight sizeChild:sizeChildLeft positionX:0];
                        if ([parenDict objectForKey:EDKeyParenthesisTextField]){
                            [otherFields addObject:[parenDict objectForKey:EDKeyParenthesisTextField]];
                            parenWidth += [[parenDict objectForKey:EDKeyParenthesisWidth] floatValue];
                            _parenLeftWidth += parenWidth;
                        }
                    }
                
                    // left child
                    [self addSubview:[self childLeft]];
                    [[self childLeft] setFrameOrigin:NSMakePoint(parenWidth, largerHeight-sizeChildLeft.height)];
                    sizeChildLeft.width = [[self childLeft] frame].size.width;
                
                    float fontSizeMultiply = currentTokenFontSize * EDExpressionSymbolMultiplicationSymbolFontModifier;
                    NSSize sizeOperator;
                    
                    if ([token isImplicit]){
                        // if implicit then don't add size
                        sizeOperator = NSMakeSize(0, 0);
                    }
                    else{
                        // add multiply symbol
                        NSTextField *fieldMultiply = [EDExpressionNodeView generateTextField:fontSizeMultiply string:@"∙"];
                        sizeOperator = [fieldMultiply frame].size;
                        [self addSubview:fieldMultiply];
                        [fieldMultiply setFrameOrigin:NSMakePoint(parenWidth + sizeChildLeft.width, 0)];
                        [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldMultiply];
                        [otherFields addObject:fieldMultiply];
                        [multiplyFields addObject:fieldMultiply];
                    }
                    
                    
                    // right child
                    [self addSubview:[self childRight]];
                    [[self childRight] setFrameOrigin:NSMakePoint(parenWidth + sizeChildLeft.width + sizeOperator.width, largerHeight-sizeChildRight.height)];
                    sizeChildRight.width = [[self childRight] frame].size.width;
                    
                    // add parenthesis after right child
                    for (int i=0; i<[[[self token] parenthesisCount] intValue]; i++){
                        parenDict = [self addParenthesis:@")" largerHeight:largerHeight sizeChild:sizeChildLeft positionX:parenWidth + sizeChildLeft.width + sizeOperator.width + sizeChildRight.width];
                        if ([parenDict objectForKey:EDKeyParenthesisTextField]){
                            [otherFields addObject:[parenDict objectForKey:EDKeyParenthesisTextField]];
                            parenWidth += [[parenDict objectForKey:EDKeyParenthesisWidth] floatValue];
                        }
                    }
                    
                    [self setFrameSize:NSMakeSize(parenWidth + sizeChildLeft.width + sizeOperator.width + sizeChildRight.width, largerHeight)];
                    [self setVerticalPositions:otherFields multiplyFields:nil fontSize:currentTokenFontSize];
                }
            }
            else if (([[[self childLeft] token] typeRaw] == EDTokenTypeOperator) || ([[[self childRight] token] typeRaw] == EDTokenTypeOperator)){
                // one of the children is an operator and the other one is an identifier/number
                // need to surround the operator with parenthesis
                EDExpressionNodeView *childOperator, *childIdentifierNumber;
                
                if ([[[self childLeft] token] typeRaw] == EDTokenTypeOperator){
                    childOperator = [self childLeft];
                    childIdentifierNumber = [self childRight];
                }
                else{
                    childOperator = [self childRight];
                    childIdentifierNumber = [self childLeft];
                }
                
                if (([[childLeft token] typeRaw] == EDTokenTypeNumber) && (childOperator == childRight) && ([[[childOperator token] tokenValue] isEqualToString:@"^"])){
                    // multiply an identifier/number with an exponent
                    // exponent is on the right side
                    NSSize sizeOperator = [childOperator frame].size;
                    NSSize sizeIdentifierNumber = [childIdentifierNumber frame].size;
                    //float largerHeight = MAX(sizeOperator.height, sizeIdentifierNumber.height);
                    NSSize sizeMultiply;
                    NSTextField *fieldMultiply;
                    
                    // add left parenthesis
                    NSDictionary *parenDict;
                    float parenWidth=0;
                    for (int i=0; i<[[[self token] parenthesisCount] intValue]; i++){
                        //parenDict = [self addParenthesis:@"(" largerHeight:largerHeight sizeChild:sizeChildLeft positionX:0];
                        parenDict = [self addParenthesis:@"(" largerHeight:largerHeight sizeChild:largerSize positionX:0];
                        if ([parenDict objectForKey:EDKeyParenthesisTextField]){
                            [otherFields addObject:[parenDict objectForKey:EDKeyParenthesisTextField]];
                            parenWidth += [[parenDict objectForKey:EDKeyParenthesisWidth] floatValue];
                            _parenLeftWidth += parenWidth;
                        }
                    }
                
                    
                    // left child identifier/number
                    [self addSubview:childIdentifierNumber];
                    [childIdentifierNumber setFrameOrigin:NSMakePoint(parenWidth, largerHeight-sizeIdentifierNumber.height)];
                    
                    // add multiply symbol
                    if (![token isImplicit]){
                        float fontSizeMultiply = currentTokenFontSize * EDExpressionSymbolMultiplicationSymbolFontModifier;
                        fieldMultiply = [EDExpressionNodeView generateTextField:fontSizeMultiply string:@"∙"];
                        sizeMultiply = [fieldMultiply frame].size;
                        [self addSubview:fieldMultiply];
                        [fieldMultiply setFrameOrigin:NSMakePoint(parenWidth + sizeChildLeft.width, 0)];
                        [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldMultiply];
                        [otherFields addObject:fieldMultiply];
                        [multiplyFields addObject:fieldMultiply];
                    }
                    else{
                        sizeMultiply = NSMakeSize(0, 0);
                    }
                    
                    // right child
                    [self addSubview:childOperator];
                    [childOperator setFrameOrigin:NSMakePoint(parenWidth + sizeIdentifierNumber.width + sizeMultiply.width, largerHeight-sizeOperator.height)];
                    
                    // add right parenthesis
                    for (int i=0; i<[[[self token] parenthesisCount] intValue]; i++){
                        parenDict = [self addParenthesis:@")" largerHeight:largerHeight sizeChild:sizeChildLeft positionX:parenWidth + sizeIdentifierNumber.width + sizeMultiply.width + sizeOperator.width];
                        if ([parenDict objectForKey:EDKeyParenthesisTextField]){
                            [otherFields addObject:[parenDict objectForKey:EDKeyParenthesisTextField]];
                            parenWidth += [[parenDict objectForKey:EDKeyParenthesisWidth] floatValue];
                        }
                    }
                    
                    [self setFrameSize:NSMakeSize(parenWidth + sizeOperator.width + sizeMultiply.width + sizeIdentifierNumber.width, largerHeight)];
                    [self setVerticalPositions:otherFields multiplyFields:multiplyFields fontSize:currentTokenFontSize];
                }
                else if ([[[childOperator token] tokenValue] isEqualToString:@"*"]){
                    //NSLog(@"one is operator and another is a child. token:%@", [token tokenValue]);
                    // determine larger height
                    NSSize sizeOperator = [childOperator frame].size;
                    NSSize sizeIdentifierNumber = [childIdentifierNumber frame].size;
                    float largerHeight = MAX(sizeOperator.height, sizeIdentifierNumber.height);
                    NSSize sizeMultiply;
                    NSTextField *fieldMultiply;
                    
                    
                    // add left parenthesis
                    NSDictionary *parenDict;
                    float parenWidth=0;
                    for (int i=0; i<[[[self token] parenthesisCount] intValue]; i++){
                        parenDict = [self addParenthesis:@"(" largerHeight:largerHeight sizeChild:sizeChildLeft positionX:0];
                        if ([parenDict objectForKey:EDKeyParenthesisTextField]){
                            [otherFields addObject:[parenDict objectForKey:EDKeyParenthesisTextField]];
                            parenWidth += [[parenDict objectForKey:EDKeyParenthesisWidth] floatValue];
                            _parenLeftWidth += parenWidth;
                        }
                    }
                    
                    // just multiply tokens together
                    // left child
                    [self addSubview:childLeft];
                    [childLeft setFrameOrigin:NSMakePoint(parenWidth, largerHeight-sizeChildLeft.height)];
                                                          
                    // add multiply symbol
                    if (![token isImplicit]){
                        float fontSizeMultiply = currentTokenFontSize * EDExpressionSymbolMultiplicationSymbolFontModifier;
                        fieldMultiply = [EDExpressionNodeView generateTextField:fontSizeMultiply string:@"∙"];
                        sizeMultiply = [fieldMultiply frame].size;
                        [self addSubview:fieldMultiply];
                        [fieldMultiply setFrameOrigin:NSMakePoint(parenWidth + sizeChildLeft.width, 0)];
                        [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldMultiply];
                        [otherFields addObject:fieldMultiply];
                        [multiplyFields addObject:fieldMultiply];
                    }
                    else{
                        sizeMultiply = NSMakeSize(0, 0);
                    }
                    
                    // right child
                    [self addSubview:childRight];
                    [childRight setFrameOrigin:NSMakePoint(parenWidth + sizeChildLeft.width + sizeMultiply.width, largerHeight-sizeChildRight.height)];
                    
                    // add right parenthesis
                    for (int i=0; i<[[[self token] parenthesisCount] intValue]; i++){
                        parenDict = [self addParenthesis:@")" largerHeight:largerHeight sizeChild:sizeChildLeft positionX:parenWidth + sizeChildLeft.width + sizeMultiply.width + sizeChildRight.width];
                        if ([parenDict objectForKey:EDKeyParenthesisTextField]){
                            [otherFields addObject:[parenDict objectForKey:EDKeyParenthesisTextField]];
                            parenWidth += [[parenDict objectForKey:EDKeyParenthesisWidth] floatValue];
                        }
                    }
                    
                    // set frame size
                    [self setFrameSize:NSMakeSize(parenWidth + sizeChildLeft.width + sizeMultiply.width + sizeChildRight.width, largerHeight)];
                    [self setVerticalPositions:otherFields multiplyFields:multiplyFields fontSize:currentTokenFontSize];
                }
                else{
                    // determine larger height
                    float heightOperator = [childOperator frame].size.height;
                    float heightIdentifierNumber = [childIdentifierNumber frame].size.height;
                    float largerHeight = MAX(heightOperator, heightIdentifierNumber);
                    //float fontSizeParenthesis = [EDExpressionNodeView fontSizeForString:@"(" height:[childOperator frame].size.height];
                    
                    // figure out which child to surround with parenthesis
                    if ([[[self childRight] token] typeRaw] == EDTokenTypeOperator){
                        // right child is operator
                        
                        // add left parenthesis
                        NSDictionary *parenDict;
                        float parenWidth=0;
                        for (int i=0; i<[[[self token] parenthesisCount] intValue]; i++){
                            parenDict = [self addParenthesis:@"(" largerHeight:largerHeight sizeChild:sizeChildLeft positionX:0];
                            if ([parenDict objectForKey:EDKeyParenthesisTextField]){
                                [otherFields addObject:[parenDict objectForKey:EDKeyParenthesisTextField]];
                                parenWidth += [[parenDict objectForKey:EDKeyParenthesisWidth] floatValue];
                                _parenLeftWidth += parenWidth;
                            }
                        }
                        
                        // left child
                        [self addSubview:childLeft];
                        [childLeft setFrameOrigin:NSMakePoint(parenWidth, largerHeight-sizeChildLeft.height)];
                        
                        // multiplication operator
                        NSSize sizeOperator;
                        NSTextField *fieldMultiply;
                        float fontSizeMultiplier = currentTokenFontSize * EDExpressionSymbolMultiplicationSymbolFontModifier;
                        if (![token isImplicit]){
                            fieldMultiply = [EDExpressionNodeView generateTextField:fontSizeMultiplier string:@"∙"];
                            sizeOperator = [fieldMultiply frame].size;
                            [self addSubview:fieldMultiply];
                            [fieldMultiply setFrameOrigin:NSMakePoint(parenWidth + sizeChildLeft.width, 0)];
                            [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldMultiply];
                            [otherFields addObject:fieldMultiply];
                            [multiplyFields addObject:fieldMultiply];
                        }
                        else{
                            sizeOperator = NSMakeSize(0, 0);
                        }
                        
                        // right child
                        [self addSubview:childRight];
                        [childRight setFrameOrigin:NSMakePoint(parenWidth + sizeChildLeft.width + sizeOperator.width, largerHeight-sizeChildRight.height)];
                        
                        // add right parenthesis
                        for (int i=0; i<[[[self token] parenthesisCount] intValue]; i++){
                            parenDict = [self addParenthesis:@")" largerHeight:largerHeight sizeChild:sizeChildLeft positionX:parenWidth + sizeChildLeft.width + sizeOperator.width + sizeChildRight.width];
                            if ([parenDict objectForKey:EDKeyParenthesisTextField]){
                                [otherFields addObject:[parenDict objectForKey:EDKeyParenthesisTextField]];
                                parenWidth += [[parenDict objectForKey:EDKeyParenthesisWidth] floatValue];
                            }
                        }
                        
                        // adjustments
                        [self setFrameSize:NSMakeSize(parenWidth + sizeChildLeft.width + sizeOperator.width + sizeChildRight.width, largerHeight)];
                        [self setVerticalPositions:otherFields multiplyFields:multiplyFields fontSize:currentTokenFontSize];
                    }
                    else{
                        // left child is the operator
                        // add left parenthesis
                        NSDictionary *parenDict;
                        float parenWidth=0;
                        for (int i=0; i<[[[self token] parenthesisCount] intValue]; i++){
                            parenDict = [self addParenthesis:@"(" largerHeight:largerHeight sizeChild:sizeChildLeft positionX:0];
                            if ([parenDict objectForKey:EDKeyParenthesisTextField]){
                                [otherFields addObject:[parenDict objectForKey:EDKeyParenthesisTextField]];
                                parenWidth += [[parenDict objectForKey:EDKeyParenthesisWidth] floatValue];
                                _parenLeftWidth += parenWidth;
                            }
                        }
                        
                        // left child
                        [self addSubview:childLeft];
                        [childLeft setFrameOrigin:NSMakePoint(parenWidth, largerHeight-sizeChildLeft.height)];
                        sizeChildLeft.width = [childLeft frame].size.width;
                        
                        // multiplication operator
                        NSSize sizeOperator;
                        NSTextField *fieldMultiply;
                        float fontSizeMultiplier = currentTokenFontSize * EDExpressionSymbolMultiplicationSymbolFontModifier;
                        
                        if (![token isImplicit]){
                            fieldMultiply = [EDExpressionNodeView generateTextField:fontSizeMultiplier string:@"∙"];
                            sizeOperator = [fieldMultiply frame].size;
                            [self addSubview:fieldMultiply];
                            [fieldMultiply setFrameOrigin:NSMakePoint(parenWidth + sizeChildLeft.width, 0)];
                            [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldMultiply];
                            [otherFields addObject:fieldMultiply];
                            [multiplyFields addObject:fieldMultiply];
                        }
                        else{
                            sizeOperator = NSMakeSize(0, 0);
                        }
                        
                        // right child
                        [self addSubview:childRight];
                        [childRight setFrameOrigin:NSMakePoint(parenWidth + sizeChildLeft.width + sizeOperator.width, largerHeight-sizeChildRight.height)];
                        sizeChildRight.width = [childRight frame].size.width;
                        
                        // add right parenthesis
                        for (int i=0; i<[[[self token] parenthesisCount] intValue]; i++){
                            parenDict = [self addParenthesis:@")" largerHeight:largerHeight sizeChild:sizeChildLeft positionX:parenWidth + sizeChildLeft.width + sizeOperator.width + sizeChildRight.width];
                            if ([parenDict objectForKey:EDKeyParenthesisTextField]){
                                [otherFields addObject:[parenDict objectForKey:EDKeyParenthesisTextField]];
                                parenWidth += [[parenDict objectForKey:EDKeyParenthesisWidth] floatValue];
                            }
                        }

                        [self setFrameSize:NSMakeSize(parenWidth + sizeChildLeft.width + sizeOperator.width + sizeChildRight.width, largerHeight)];
                        [self setVerticalPositions:otherFields multiplyFields:multiplyFields fontSize:currentTokenFontSize];
                    }
                }
            }
            else if ((([[[self childLeft] token] typeRaw] == EDTokenTypeNumber) && ([[[self childRight] token] typeRaw] == EDTokenTypeNumber)) ||
                     (([[[self childLeft] token] typeRaw] == EDTokenTypeIdentifier) && ([[[self childRight] token] typeRaw] == EDTokenTypeIdentifier))){
                // two identifiers/numbers, place multiplication symbol in between
                float fontSizeMultiply = currentTokenFontSize * EDExpressionSymbolMultiplicationSymbolFontModifier;
                NSSize sizeOperator;
                
                // add left parenthesis
                NSDictionary *parenDict;
                float parenWidth=0;
                for (int i=0; i<[[[self token] parenthesisCount] intValue]; i++){
                    parenDict = [self addParenthesis:@"(" largerHeight:largerHeight sizeChild:sizeChildLeft positionX:0];
                    if ([parenDict objectForKey:EDKeyParenthesisTextField]){
                        [otherFields addObject:[parenDict objectForKey:EDKeyParenthesisTextField]];
                        parenWidth += [[parenDict objectForKey:EDKeyParenthesisWidth] floatValue];
                        _parenLeftWidth += parenWidth;
                    }
                }
                
                // left child
                [self addSubview:[self childLeft]];
                [[self childLeft] setFrameOrigin:NSMakePoint(parenWidth, 0)];
                
                // add multiply symbol
                if (![token isImplicit]){
                    NSTextField *fieldMultiply = [EDExpressionNodeView generateTextField:fontSizeMultiply string:@"∙"];
                    sizeOperator = [fieldMultiply frame].size;
                    [self addSubview:fieldMultiply];
                    [fieldMultiply setFrameOrigin:NSMakePoint(parenWidth + sizeChildLeft.width, 0)];
                    [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldMultiply];
                    [otherFields addObject:fieldMultiply];
                    [multiplyFields addObject:fieldMultiply];
                }
                else{
                    sizeOperator = NSMakeSize(0, 0);
                }
                
                // right child
                [self addSubview:[self childRight]];
                [[self childRight] setFrameOrigin:NSMakePoint(parenWidth + sizeChildLeft.width + sizeOperator.width, 0)];
                sizeChildRight.width = [[self childRight] frame].size.width;
                
                // add right parenthesis
                for (int i=0; i<[[[self token] parenthesisCount] intValue]; i++){
                    parenDict = [self addParenthesis:@")" largerHeight:largerHeight sizeChild:sizeChildLeft positionX:parenWidth + sizeChildLeft.width + sizeOperator.width + sizeChildRight.width];
                    if ([parenDict objectForKey:EDKeyParenthesisTextField]){
                        [otherFields addObject:[parenDict objectForKey:EDKeyParenthesisTextField]];
                        parenWidth += [[parenDict objectForKey:EDKeyParenthesisWidth] floatValue];
                    }
                }
                
                [self setFrameSize:NSMakeSize(parenWidth + sizeChildLeft.width + sizeOperator.width + sizeChildRight.width, largerHeight)];
                [self setVerticalPositions:otherFields multiplyFields:multiplyFields fontSize:currentTokenFontSize];
            }
            else{
                // one child is an identifier and the other is a number
                // put the number in front
                NSSize sizeOperator;
                float fontSizeMultiply = currentTokenFontSize * EDExpressionSymbolMultiplicationSymbolFontModifier;
                
                // add left parenthesis
                NSDictionary *parenDict;
                float parenWidth=0;
                for (int i=0; i<[[[self token] parenthesisCount] intValue]; i++){
                    parenDict = [self addParenthesis:@"(" largerHeight:largerHeight sizeChild:sizeChildLeft positionX:0];
                    if ([parenDict objectForKey:EDKeyParenthesisTextField]){
                        [otherFields addObject:[parenDict objectForKey:EDKeyParenthesisTextField]];
                        parenWidth += [[parenDict objectForKey:EDKeyParenthesisWidth] floatValue];
                        _parenLeftWidth += parenWidth;
                    }
                }
                
                // left child
                [self addSubview:childLeft];
                [[self childLeft] setFrameOrigin:NSMakePoint(parenWidth, 0)];
                
                // add multiply symbol
                if (![token isImplicit]){
                    NSTextField *fieldMultiply = [EDExpressionNodeView generateTextField:fontSizeMultiply string:@"∙"];
                    sizeOperator = [fieldMultiply frame].size;
                    [self addSubview:fieldMultiply];
                    [fieldMultiply setFrameOrigin:NSMakePoint(parenWidth + sizeChildLeft.width, 0)];
                    [_addedSubviewsOtherThanRightAndLeftChildren addObject:fieldMultiply];
                    [otherFields addObject:fieldMultiply];
                    [multiplyFields addObject:fieldMultiply];
                }
                else{
                    sizeOperator = NSMakeSize(0, 0);
                }
                
                // right child
                [self addSubview:childRight];
                [childRight setFrameOrigin:NSMakePoint(parenWidth + sizeChildLeft.width + sizeOperator.width, 0)];
                
                // add right parenthesis
                for (int i=0; i<[[[self token] parenthesisCount] intValue]; i++){
                    parenDict = [self addParenthesis:@")" largerHeight:largerHeight sizeChild:sizeChildLeft positionX:parenWidth + sizeChildLeft.width + sizeOperator.width + sizeChildRight.width];
                    if ([parenDict objectForKey:EDKeyParenthesisTextField]){
                        [otherFields addObject:[parenDict objectForKey:EDKeyParenthesisTextField]];
                        parenWidth += [[parenDict objectForKey:EDKeyParenthesisWidth] floatValue];
                    }
                }
                
 
                [self setFrameSize:NSMakeSize(parenWidth + sizeChildLeft.width + sizeOperator.width + sizeChildRight.width, largerHeight)];
                [self setVerticalPositions:otherFields multiplyFields:multiplyFields fontSize:currentTokenFontSize];
            }
        }
        else if([[[self token] tokenValue] isEqualToString:@"^"]){
            if ([[[[self childRight] token] tokenValue] isEqualToString:@"/"]){
                if ([[[self childLeft] token] typeRaw] == EDTokenTypeOperator){
                    // for root symbols the baseline is not used and vertical positions are not adjusted
                    // draw the base surrounded by parenthesis with the numerator exponent and a root symbol
                    float parenWidthLeft=0, parenWidthRight=0, widthRadicalRoot=0, widthRadicalPower=0, fontSizeParenthesis=0;
                    NSSize sizeRadicalRoot, sizeRadicalPower;
                    EDExpressionNodeView *radicalPower = [[self childRight] childLeft];
                    EDExpressionNodeView *radicalRoot = [[self childRight] childRight];
                    sizeRadicalPower = [[[self childRight] childLeft] frame].size;
                    sizeRadicalRoot = [[[self childRight] childRight] frame].size;
                    _radicalBaseWidth = 0;
                    _radicalBaseLeftParenWidth = 0;
                    
                    // determine font size if it's a divide operation
                    fontSizeParenthesis = [EDExpressionNodeView fontSizeForString:@"(" height:[[self childLeft] frame].size.height];
                    
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
                    
                    // radical base
                    [self addSubview:childLeft];
                    sizeChildLeft.width = [childLeft frame].size.width;
                    _radicalBaseWidth += sizeChildLeft.width;
                    [childLeft setFrameOrigin:NSMakePoint(_radicalRootWidth + parenWidthLeft, _radicalRootHeight + EDExpressionRadicalPowerOffsetVertical)];
                    
                    // add right paren
                    // if radical power is 1 then don't show it
                    if ([[[radicalPower token] tokenValue] isEqualToString:@"1"]){
                    }
                    else{
                        [self addSubview:radicalPower];
                        [_addedSubviewsOtherThanRightAndLeftChildren addObject:radicalPower];
                        widthRadicalPower = sizeRadicalPower.width;
                        _radicalBaseWidth += widthRadicalPower;
                        _radicalPowerHeight = sizeRadicalPower.height;
                        [radicalPower setFrameOrigin:NSMakePoint(_radicalRootWidth + parenWidthLeft + sizeChildLeft.width + parenWidthRight, _radicalRootHeight + EDExpressionRadicalPowerOffsetVertical)];
                    }
                    
                    // set frame size
                    [self setFrameSize:NSMakeSize(_radicalRootWidth + parenWidthLeft + sizeChildLeft.width + parenWidthRight + widthRadicalPower, largerHeight + _radicalRootHeight + EDExpressionRadicalPowerOffsetVertical)];
                }
                else{
                    // for root symbols the baseline is not used and vertical positions are not adjusted
                    // draw the base surrounded by parenthesis with the numerator exponent and a root symbol
                    float widthRadicalRoot=0, widthRadicalPower=0;
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
                    sizeChildLeft.width = [childLeft frame].size.width;
                    _radicalBaseWidth += sizeChildLeft.width;
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
                        [radicalPower setFrameOrigin:NSMakePoint(_radicalRootWidth + sizeChildLeft.width , _radicalRootHeight+EDExpressionRadicalPowerOffsetVertical)];
                    }
                    
                    // set frame size
                    [self setFrameSize:NSMakeSize(_radicalRootWidth  + _radicalBaseWidth, largerHeight + _radicalRootHeight + EDExpressionRadicalPowerOffsetVertical)];
                }
            }
            else if ([[[self childLeft] token] typeRaw] == EDTokenTypeOperator){
                // add left parenthesis
                NSDictionary *parenDict;
                float parenWidth=0;
                NSSize baseExponentSize = NSMakeSize(sizeChildLeft.width + sizeChildRight.width, sizeChildLeft.height + sizeChildRight.height+ EDExpressionExponentPowerExponentModifierVertical*currentTokenFontSize);
                for (int i=0; i<[[[self token] parenthesisCount] intValue]; i++){
                    //NSLog(@"adding paren: left height:%f right height:%f offset:%f", sizeChildLeft.height, sizeChildRight.height, EDExpressionExponentPowerExponentModifierVertical*currentTokenFontSize);
                    parenDict = [self addParenthesis:@"(" largerHeight:sizeChildLeft.height + sizeChildRight.height+ EDExpressionExponentPowerExponentModifierVertical*currentTokenFontSize sizeChild:baseExponentSize positionX:0];
                    if ([parenDict objectForKey:EDKeyParenthesisTextField]){
                        [otherFields addObject:[parenDict objectForKey:EDKeyParenthesisTextField]];
                        parenWidth += [[parenDict objectForKey:EDKeyParenthesisWidth] floatValue];
                        _parenLeftWidth += parenWidth;
                    }
                }
            
                // left child
                [self addSubview:childLeft];
                [childLeft setFrameOrigin:NSMakePoint(parenWidth, sizeChildRight.height + EDExpressionExponentPowerExponentModifierVertical*currentTokenFontSize)];
            
                // right child
                [self addSubview:[self childRight]];
                [childRight setFrameOrigin:NSMakePoint(parenWidth + sizeChildLeft.width, 0)];
                
                // add right parenthesis
                for (int i=0; i<[[[self token] parenthesisCount] intValue]; i++){
                    parenDict = [self addParenthesis:@")" largerHeight:largerHeight sizeChild:sizeChildLeft positionX:parenWidth + sizeChildLeft.width + sizeChildRight.width];
                    if ([parenDict objectForKey:EDKeyParenthesisTextField]){
                        [otherFields addObject:[parenDict objectForKey:EDKeyParenthesisTextField]];
                        parenWidth += [[parenDict objectForKey:EDKeyParenthesisWidth] floatValue];
                    }
                }
                
                // set frame size
                [self setFrameSize:NSMakeSize(parenWidth + sizeChildLeft.width + sizeChildRight.width, sizeChildRight.height + EDExpressionExponentPowerExponentModifierVertical * currentTokenFontSize + sizeChildLeft.height)];
                [self setVerticalPositions:otherFields multiplyFields:nil fontSize:currentTokenFontSize];
            }
            else {
                
                // add left parenthesis
                NSDictionary *parenDict;
                float parenWidth=0;
                NSSize baseExponentSize = NSMakeSize(sizeChildLeft.width + sizeChildRight.width, sizeChildLeft.height + sizeChildRight.height+ EDExpressionExponentPowerExponentModifierVertical*currentTokenFontSize);
                for (int i=0; i<[[[self token] parenthesisCount] intValue]; i++){
                    //parenDict = [self addParenthesis:@"(" largerHeight:largerHeight sizeChild:sizeChildLeft positionX:0];
                    parenDict = [self addParenthesis:@"(" largerHeight:baseExponentSize.height sizeChild:baseExponentSize positionX:0];
                    if ([parenDict objectForKey:EDKeyParenthesisTextField]){
                        [otherFields addObject:[parenDict objectForKey:EDKeyParenthesisTextField]];
                        parenWidth += [[parenDict objectForKey:EDKeyParenthesisWidth] floatValue];
                        _parenLeftWidth += parenWidth;
                    }
                }

                // left child
                [self addSubview:childLeft];
                sizeChildLeft.width = [childLeft frame].size.width;
                [childLeft setFrameOrigin:NSMakePoint(parenWidth, sizeChildRight.height+EDExpressionExponentPowerExponentModifierVertical*currentTokenFontSize)];
                
                // right child
                [self addSubview:[self childRight]];
                [childRight setFrameOrigin:NSMakePoint(parenWidth + sizeChildLeft.width, 0)];
                sizeChildRight.width = [[self childRight] frame].size.width;
            
                // add right parenthesis
                for (int i=0; i<[[[self token] parenthesisCount] intValue]; i++){
                    parenDict = [self addParenthesis:@")" largerHeight:baseExponentSize.height sizeChild:baseExponentSize positionX:parenWidth + sizeChildLeft.width + sizeChildRight.width];
                    if ([parenDict objectForKey:EDKeyParenthesisTextField]){
                        [otherFields addObject:[parenDict objectForKey:EDKeyParenthesisTextField]];
                        parenWidth += [[parenDict objectForKey:EDKeyParenthesisWidth] floatValue];
                    }
                }
                
                // set frame size
                [self setFrameSize:NSMakeSize(parenWidth + sizeChildLeft.width + sizeChildRight.width, sizeChildRight.height + EDExpressionExponentPowerExponentModifierVertical*currentTokenFontSize + sizeChildLeft.height)];
                //NSLog(@"width child left:%f child right:%f total width:%f", sizeChildLeft.width, sizeChildRight.width, [self frame].size.width);
                [self setVerticalPositions:nil multiplyFields:nil fontSize:currentTokenFontSize];
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