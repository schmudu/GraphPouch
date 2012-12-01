//
//  EDScanner.h
//  GraphPouch
//
//  Created by PATRICK LEE on 11/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EDScanner : NSObject{
}

+ (void)scanString:(NSString *)p_str;
+ (NSString *)currentChar;
+ (int)charCount;
+ (void)increment;
@end
