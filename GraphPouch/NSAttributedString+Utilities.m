//
//  NSAttributedString+Utilities.m
//  GraphPouch
//
//  Created by PATRICK LEE on 2/15/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "NSAttributedString+Utilities.h"

@implementation NSAttributedString (Utilities)

- (BOOL)hasAttribute:(NSString *)attribute forIndex:(NSInteger)index{
    NSRange range = NSMakeRange(index, 0);
    __block BOOL result = FALSE;
    [self enumerateAttribute:attribute inRange:range options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange blockRange, BOOL *stop) {
        if ((int)value == 1){
            result = TRUE;
            return;
        }
        else{
            result = TRUE;
            return;
        }
    }];
    return result;
}
@end
