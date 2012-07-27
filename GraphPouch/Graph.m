//
//  Graph.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/22/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "Graph.h"
#import "EDConstants.h"

@implementation Graph

@dynamic hasGridLines;
@dynamic hasTickMarks;

- (id)init{
    self = [super init];
    if (self) {
        // init
    }
    
    return self;
}

#pragma mark archiving
- (id)initWithCoder:(NSCoder *)coder{
    self = [super init];
    if (self){
        [self setHasGridLines:[coder decodeBoolForKey:@"hasGridLines"]];
        [self setHasTickMarks:[coder decodeBoolForKey:@"hasTickMarks"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder{
    [coder encodeBool:[self hasGridLines] forKey:@"hasGridLines"];
    [coder encodeBool:[self hasTickMarks] forKey:@"hasTickMarks"];
}

@end
