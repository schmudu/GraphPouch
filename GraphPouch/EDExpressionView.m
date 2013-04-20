//
//  EDExpressionView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 4/15/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDExpressionView.h"
#import "NSColor+Utilities.h"

@interface EDExpressionView()
- (void)validateAndDisplayExpression;
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
        
        _drawSeleection = drawSelection;
        
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
    if ((_drawSeleection) && ([(EDExpression *)[self dataObj] selected])){
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
            
            // add a small buffer to the equal sign
            equalSize.width += 0.5;
            
            NSTextField *equalField = [EDExpressionNodeView generateTextField:NSMakeRect(0, 0, equalSize.width, equalSize.height)];
            NSMutableAttributedString *equalString = [[NSMutableAttributedString alloc] initWithString:@"="];
            [equalField setFont:[NSFont fontWithName:EDExpressionDefaultFontName size:[(EDExpression *)[self dataObj] fontSize]]];
            [equalField setAttributedStringValue:equalString];
            
            // get larger height
            float heightFirst = [rootNodeFirst frame].size.height;
            float heightSecond = [rootNodeSecond frame].size.height;
            float largerHeight = MAX(heightFirst, heightSecond);
            
            [self addSubview:equalField];
            [equalField setFrameOrigin:NSMakePoint([rootNodeFirst frame].size.width, (largerHeight-equalSize.height)/2)];
            
            // add image to worksheet
            [self addSubview:rootNodeSecond];
            if (heightSecond > heightFirst)
                [rootNodeSecond setFrameOrigin:NSMakePoint([rootNodeFirst frame].size.width + equalSize.width, 0)];
            else
                [rootNodeSecond setFrameOrigin:NSMakePoint([rootNodeFirst frame].size.width + equalSize.width, (largerHeight-[rootNodeSecond frame].size.height)/2)];
            
            // adjust first height
            if (heightFirst > heightSecond)
                [rootNodeFirst setFrameOrigin:NSMakePoint(0, 0)];
            else
                [rootNodeFirst setFrameOrigin:NSMakePoint(0, (largerHeight-[rootNodeFirst frame].size.height)/2)];
        }
    }
}
@end
