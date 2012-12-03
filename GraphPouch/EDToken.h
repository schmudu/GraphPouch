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
} 
@property EDTokenType type;
@property BOOL valid;
@property int precedence;
@property EDAssociation association;
@property NSString *value;


+ (EDToken *)multiplierToken;
+ (EDToken *)leftParenToken;
+ (EDToken *)rightParentToken;
- (void)appendChar:(NSString *)c;
- (int)length;
- (EDToken *)copy;

@end
