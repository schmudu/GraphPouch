//
//  EDGraphViewPrint.m
//  GraphPouch
//
//  Created by PATRICK LEE on 2/17/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDConstants.h"
#import "EDGraph.h"
#import "EDGraphView.h"
#import "EDGraphViewPrint.h"

@implementation EDGraphViewPrint

- (id)initWithFrame:(NSRect)frame graphModel:(EDGraph *)myGraph{
    self = [super initWithFrame:frame graphModel:myGraph drawSelection:FALSE];
    
    if (self){
        // do some other printing stuff
        [self drawElementAttributes];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect{
}
@end
