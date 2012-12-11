//
//  EDStack.m
//  GraphPouch
//
//  Created by PATRICK LEE on 12/2/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDStack.h"

@implementation EDStack
@synthesize count;

- (id)init{
    self = [super init];
    if (self){
        _stack = [[NSMutableArray alloc] init];
        count = 0;
    }
    return self;
}

- (void)push:(id)anObject{
    [_stack addObject:anObject];
}

- (id)pop{
    id obj = nil;
    if ([_stack count]>0) {
        obj = [_stack lastObject];
        [_stack removeLastObject];
        count = [_stack count];
    }
    return obj;
}

- (void)clear{
    [_stack removeAllObjects];
    count = 0;
}

- (id)getLastObject{
    if([_stack count] > 0){
        return [_stack objectAtIndex:([_stack count]-1)];
    }
    return nil;
}

- (void)printAll:(NSString *)key{
    int j = 0;
    for (id obj in _stack){
        NSLog(@"index: %d obj: %@", j, [obj valueForKey:key]);
        j++;
    }
}
@end
