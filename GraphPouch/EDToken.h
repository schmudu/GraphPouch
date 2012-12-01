//
//  EDToken.h
//  GraphPouch
//
//  Created by PATRICK LEE on 11/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EDConstants.h"

@interface EDToken : NSObject{
@private
    NSMutableDictionary *attributes;
}
@property EDTokenType type;
@property BOOL valid;
@property int precedence;
@property EDAssociation association;
    

+ (EDToken *)multiplierToken;
+ (EDToken *)leftParenToken;
+ (EDToken *)rightParentToken;
- (void)appendChar:(NSString *)c;
- (int)length;
- (NSString *)value;
- (void)setValue:(NSString *)value;
- (EDToken *)copy;

@end
