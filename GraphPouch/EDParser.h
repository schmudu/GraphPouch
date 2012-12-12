//
//  EDParser.h
//  GraphPouch
//
//  Created by PATRICK LEE on 12/11/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EDParser : NSObject

- (NSMutableArray *)parse:(NSMutableArray *)tokens error:(NSError **)error;
- (NSMutableArray *)calculate:(NSMutableArray *)stack error:(NSError **)error;

@end
