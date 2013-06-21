//
//  EDExpressionView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 4/15/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility.h"
#import "EDExpressionView.h"
#import "NSColor+Utilities.h"

@interface EDExpressionView()
@end

@implementation EDExpressionView

+ (EDExpressionNodeView *)createExpressionNodeTree:(NSArray *)stack frame:(NSRect)frame expression:(EDExpression *)expression{
    int i = 0;
    BOOL firstNodeInserted = FALSE;
    EDExpressionNodeView *newNode=nil, *rootNode=nil;
    EDToken *token;
    NSMutableArray *treeArray = [NSMutableArray array];
    
    while (i<[stack count]){
        // create node from token
        token = (EDToken *)[stack objectAtIndex:([stack count]-i-1)];
        newNode = [[EDExpressionNodeView alloc] initWithFrame:frame token:token expression:expression];
        
        if (!firstNodeInserted){
            rootNode = newNode;
            firstNodeInserted = TRUE;
        }
        else
            [rootNode insertNodeIntoRightMostChild:newNode];
        
        // push node onto array
        [treeArray addObject:newNode];
        i++;
    }
    
    return rootNode;
}

- (id)initWithFrame:(NSRect)frameRect expression:(EDExpression *)expression drawSelection:(BOOL)drawSelection{
    self = [super initWithFrame:frameRect];
    if (self) {
        // set model info
        [self setDataObj:expression];
        _context = [expression managedObjectContext];
        
        _drawSelection = drawSelection;
        
        // display expression
        [self validateAndDisplayExpression];
        
        // listen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    }
    
    return self;
}

- (void)clearViews{
    // if there is a root node then destroy it and all of its subviews
    if (_rootNodeFirst){
        [_rootNodeFirst clearViews];
        
        // remove root node from view 
        [_rootNodeFirst removeFromSuperview];
    }
    
    if (_rootNodeSecond){
        [_rootNodeSecond clearViews];
        
        // remove root node from view 
        [_rootNodeSecond removeFromSuperview];
    }
    
    // clear any other subviews
    for (NSView *view in [self subviews]){
        [view removeFromSuperview];
    }
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
}

- (BOOL)isFlipped{
    return TRUE;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // color background
    if ((_drawSelection) && ([(EDExpression *)[self dataObj] selected])){
        [[NSColor colorWithHexColorString:EDGraphSelectedBackgroundColor alpha:EDGraphSelectedBackgroundAlpha] set];
        [NSBezierPath fillRect:[self bounds]];
    }
}

- (void)updateDisplayBasedOnContext{
    // this is called whenever the context for this object changes
    [super updateDisplayBasedOnContext];
 
    // clear views
    [self clearViews];
    
    // redraw expression
    [self validateAndDisplayExpression];
}

- (void)validateAndDisplayExpression{
    NSError *error;
    float newWidth = [self frame].size.width, newHeight = [self frame].size.height;
    
    // need to validate if this is an expression or equations
    NSDictionary *expressionDict = [EDExpression isValidEquationOrExpression:[(EDExpression *)[self dataObj] expression] context:_context error:&error];
    if (error){
        // create error message in view
        NSTextField *errorField = [[NSTextField alloc] initWithFrame:[self bounds]];
        [errorField setEditable:FALSE];
        [errorField setSelectable:FALSE];
        [errorField setBordered:FALSE];
        [errorField setDrawsBackground:FALSE];
        NSString *errorString = [NSString stringWithFormat:@"Error:%@", [[error userInfo] objectForKey:NSLocalizedDescriptionKey]];
        NSMutableAttributedString *errorAttributedString = [[NSMutableAttributedString alloc] initWithString:errorString];
        [errorField setFont:[NSFont fontWithName:EDExpressionDefaultFontName size:[(EDExpression *)[self dataObj] fontSize]]];
        [errorField setAttributedStringValue:errorAttributedString];
        [self addSubview:errorField];
        NSLog(@"error:%@", [[error userInfo] objectForKey:NSLocalizedDescriptionKey]);
        
        newWidth = [errorField frame].size.width;
        newHeight = [errorField frame].size.height;
    }
    else{
        // valid equation/expression
        // create tree
        EDExpressionNodeView *rootNodeFirst = [EDExpressionView createExpressionNodeTree:[expressionDict objectForKey:EDKeyExpressionFirst] frame:[self bounds] expression:(EDExpression *)[self dataObj]];
        
        // generate images
        [rootNodeFirst traverseTreeAndCreateImage];
        
        // save so we can remove it later
        _rootNodeFirst = rootNodeFirst;
        
        // add image to worksheet
        [self addSubview:rootNodeFirst];
        [rootNodeFirst setFrameOrigin:NSMakePoint(0, 0)];
        
        // if an equation then display the equal sign and the other part of the equation
        if ([[expressionDict objectForKey:EDKeyExpressionType] intValue] == EDTypeEquation){
            // create tree
            EDExpressionNodeView *rootNodeSecond = [EDExpressionView createExpressionNodeTree:[expressionDict objectForKey:EDKeyExpressionSecond] frame:[self bounds] expression:(EDExpression *)[self dataObj]];
            
            // generate images
            [rootNodeSecond traverseTreeAndCreateImage];
            
            // save so we can remove it later
            _rootNodeSecond = rootNodeSecond;
            
            // add equal sign
            NSSize equalSize = [EDExpressionNodeView getStringSize:@"=" fontSize:[(EDExpression *)[self dataObj] fontSize]];
            
            // add buffer to equal size
            float horizontalBuffer = .2*[(EDExpression *)[self dataObj] fontSize];
            
            // set field based on expressionType
            NSTextField *equalField;
            switch ([[(EDExpression *)[self dataObj] expressionEqualityType] intValue]) {
                case EDExpressionEqualityTypeEqual:
                    equalField = [EDExpressionNodeView generateTextField:[(EDExpression *)[self dataObj] fontSize] string:@"="];
                    break;
                case EDExpressionEqualityTypeGreaterThan:
                    equalField = [EDExpressionNodeView generateTextField:[(EDExpression *)[self dataObj] fontSize] string:@">"];
                    break;
                case EDExpressionEqualityTypeGreaterThanOrEqual:
                    equalField = [EDExpressionNodeView generateTextField:[(EDExpression *)[self dataObj] fontSize] string:@"≤"];
                    break;
                case EDExpressionEqualityTypeLessThan:
                    equalField = [EDExpressionNodeView generateTextField:[(EDExpression *)[self dataObj] fontSize] string:@"<"];
                    break;
                case EDExpressionEqualityTypeLessThanOrEqual:
                    equalField = [EDExpressionNodeView generateTextField:[(EDExpression *)[self dataObj] fontSize] string:@"≤"];
                    break;
                default:
                    break;
            }
            
            // get larger height
            float heightFirst = [rootNodeFirst frame].size.height;
            float heightSecond = [rootNodeSecond frame].size.height;
            float largerHeight = MAX(heightFirst, heightSecond);
            
            [self addSubview:equalField];
            
            // add image to worksheet
            [self addSubview:rootNodeSecond];
            
            // set horizontal positions
            [rootNodeFirst setFrameOrigin:NSMakePoint(0, largerHeight-[rootNodeFirst frame].size.height)];
            [equalField setFrameOrigin:NSMakePoint([rootNodeFirst frame].size.width + horizontalBuffer, largerHeight-equalSize.height)];
            [rootNodeSecond setFrameOrigin:NSMakePoint([rootNodeFirst frame].size.width + horizontalBuffer + equalSize.width + horizontalBuffer, 0)];
            
            if (([rootNodeFirst baseline]) && ([rootNodeSecond baseline])){
                // both nodes have a baseline
                // find larger baseline
                // both children have baselines
                EDExpressionNodeView *nodeLarger, *nodeSmaller;
                if ([[rootNodeFirst baseline] floatValue] > [[rootNodeSecond baseline] floatValue]){
                    nodeLarger = rootNodeFirst;
                    nodeSmaller = rootNodeSecond;
                }
                else{
                    nodeSmaller = rootNodeFirst;
                    nodeLarger = rootNodeSecond;
                }
                
                // modify positions so baselines match
                [nodeLarger setFrameOrigin:NSMakePoint([nodeLarger frame].origin.x, 0)];
                [equalField setFrameOrigin:NSMakePoint([equalField frame].size.width, [[nodeLarger baseline] floatValue] - [equalField frame].size.height)];
                [nodeSmaller setFrameOrigin:NSMakePoint([nodeSmaller frame].origin.x, [[nodeLarger baseline] floatValue] - [[nodeSmaller baseline] floatValue])];
                
                newWidth = [nodeLarger frame].size.width + horizontalBuffer + [equalField frame].size.width + horizontalBuffer + [nodeSmaller frame].size.width;
                newHeight = [nodeLarger frame].size.height;
            }
            else if (([rootNodeFirst baseline]) || ([rootNodeSecond baseline])){
                // one of the nodes has a baseline
                EDExpressionNodeView *nodeBaseline, *nodeNil;
                if ([rootNodeFirst baseline] != nil){
                    nodeBaseline = rootNodeFirst;
                    nodeNil = rootNodeSecond;
                }
                else{
                    nodeNil = rootNodeFirst;
                    nodeBaseline = rootNodeSecond;
                }
                
                // find largest value other than baseline
                if ([nodeNil frame].size.height > [[nodeBaseline baseline] floatValue]){
                    // node nil is larger than baseline
                    [nodeNil setFrameOrigin:NSMakePoint([nodeNil frame].origin.x, 0)];
                    [equalField setFrameOrigin:NSMakePoint([equalField frame].origin.x, [nodeNil frame].size.height - [equalField frame].size.height)];
                    [nodeBaseline setFrameOrigin:NSMakePoint([nodeBaseline frame].origin.x, [nodeNil frame].size.height - [[nodeBaseline baseline] floatValue])];
                    
                    newWidth = [nodeNil frame].size.width + horizontalBuffer + [equalField frame].size.width + horizontalBuffer + [nodeBaseline frame].size.width;
                    newHeight = [nodeNil frame].size.height;
                }
                else{
                    // node baseline is larger
                    [nodeNil setFrameOrigin:NSMakePoint([nodeNil frame].origin.x, [[nodeBaseline baseline] floatValue] - [nodeNil frame].size.height)];
                    [equalField setFrameOrigin:NSMakePoint([equalField frame].origin.x, [[nodeBaseline baseline] floatValue] - [equalField frame].size.height)];
                    [nodeBaseline setFrameOrigin:NSMakePoint([nodeBaseline frame].origin.x, 0)];
                    
                    newWidth = [nodeNil frame].size.width + horizontalBuffer + [equalField frame].size.width + horizontalBuffer + [nodeBaseline frame].size.width;
                    newHeight = [nodeBaseline frame].size.height;
                }
            }
            else{
                // no one has a baseline, just line up the larger one
                // find larger one
                EDExpressionNodeView *nodeLarger, *nodeSmaller;
                if ([rootNodeFirst frame].size.height > [rootNodeSecond frame].size.height){
                    nodeLarger = rootNodeFirst;
                    nodeSmaller = rootNodeSecond;
                }
                else{
                    nodeSmaller = rootNodeFirst;
                    nodeLarger = rootNodeSecond;
                }
                
                // modify positions so baselines match
                //NSLog(@"baseline larger:%f smaller:%f", [[nodeLarger baseline] floatValue], [[nodeSmaller baseline] floatValue]);
                [nodeLarger setFrameOrigin:NSMakePoint([nodeLarger frame].origin.x, 0)];
                [equalField setFrameOrigin:NSMakePoint([equalField frame].origin.x, [nodeLarger frame].size.height - [equalField frame].size.height)];
                [nodeSmaller setFrameOrigin:NSMakePoint([nodeSmaller frame].origin.x, [nodeLarger frame].size.height - [nodeSmaller frame].size.height)];
                
                newWidth = [rootNodeSecond frame].origin.x + [rootNodeSecond frame].size.width;
                newHeight = [nodeLarger frame].size.height;
            }
        }
        else{
            // just an expression, match first node
            newWidth = [rootNodeFirst frame].size.width;
            newHeight = [rootNodeFirst frame].size.height;
        }
    }
    
            
            
    //NSLog(@"baseline: autoresize: new width:%f old width:%f width second:%f", newWidth, [(EDExpression *)[self dataObj] elementWidth], [rootNodeSecond frame].size.width);
    // change if autoresize is set
    if ([(EDExpression *)[self dataObj] autoresize]){
        BOOL changed = FALSE;
        if ([(EDExpression *)[self dataObj] elementWidth] != newWidth){
            [(EDExpression *)[self dataObj] setElementWidth:newWidth];
            changed = TRUE;
        }
        
        if ([(EDExpression *)[self dataObj] elementHeight] != newHeight){
            [(EDExpression *)[self dataObj] setElementHeight:newHeight];
            changed = TRUE;
        }
        
        // if there was a change then save
        if (changed)
            [EDCoreDataUtility saveContext:_context];
    }

}
@end
