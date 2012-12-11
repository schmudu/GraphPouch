//
//  EDStack.h
//  GraphPouch
//
//  Created by PATRICK LEE on 12/2/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EDStack : NSObject{
    NSMutableArray *_stack;
}
@property int count;

- (void)push:(id)anObject;
- (id)pop;
- (void)clear;
- (id)getLastObject;
- (void)printAll:(NSString *)key;

@end
