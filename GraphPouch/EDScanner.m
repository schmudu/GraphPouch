//
//  EDScanner.m
//  GraphPouch
//
//  Created by PATRICK LEE on 11/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDScanner.h"

@implementation EDScanner
static NSString *inputString;
static int charIndex=0;

+ (void)scanString:(NSString *)p_str{
    inputString = [[NSString alloc] initWithString:p_str];
    charIndex = 0;
}

+ (NSString *)currentChar{
    unichar myChar = [inputString characterAtIndex:charIndex];
    return [NSString stringWithFormat:@"%C", myChar];
}

+ (int)charCount{
    return (int)[inputString length];
}

+ (void)increment{
    charIndex++;
}

@end
