//
//  EDExpressionView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 4/15/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDExpressionView.h"

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

- (id)initWithFrame:(NSRect)frameRect expression:(EDExpression *)expression{
    self = [super initWithFrame:frameRect];
    if (self) {
        // set model info
        [self setDataObj:expression];
        _context = [expression managedObjectContext];
        
        // display expression
        [self validateAndDisplayExpression];
        
        // listen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onContextChanged:) name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
    }
    
    return self;
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextObjectsDidChangeNotification object:_context];
}

- (BOOL)isFlipped{
    return TRUE;
}

- (void)drawRect:(NSRect)dirtyRect
{
}

- (void)validateAndDisplayExpression{
     NSError *error;
    
    // need to validate if this is an expression or equations
    NSDictionary *expressionDict = [EDExpression isValidEquationOrExpression:[(EDExpression *)[self dataObj] expression] context:_context error:&error];
    if (error){
        NSLog(@"error:%@", [[error userInfo] objectForKey:NSLocalizedDescriptionKey]);
    }
    else{
        // valid equation/expression
        // create tree
        EDExpressionNodeView *rootNode = [EDExpressionView createExpressionNodeTree:[expressionDict objectForKey:EDKeyExpressionFirst] frame:[self bounds] expression:(EDExpression *)[self dataObj]];
        
        // generate images
        [rootNode traverseTreeAndCreateImage];
        
        // add image to worksheet
        [self addSubview:rootNode];
        [rootNode setFrameOrigin:NSMakePoint(0, 0)];
    }
}
@end
