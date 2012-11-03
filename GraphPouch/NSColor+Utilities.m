//
//  NSColor+Utilities.m
//  GraphPouch
//
//  Created by PATRICK LEE on 9/14/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "NSColor+Utilities.h"

@implementation NSColor (Utilities)

+(NSColor*)colorWithHexColorString:(NSString*)inColorString{
    NSColor* result = nil;
    unsigned colorCode = 0;
    unsigned char redByte, greenByte, blueByte;

    if (nil != inColorString)
    {
        NSScanner* scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char)(colorCode >> 16);
    greenByte = (unsigned char)(colorCode >> 8);
    blueByte = (unsigned char)(colorCode); // masks off high bits

    result = [NSColor colorWithCalibratedRed:(CGFloat)redByte / 0xff
                                       green:(CGFloat)greenByte / 0xff
                                        blue:(CGFloat)blueByte / 0xff
                                       alpha:1.0];
    return result;
}

+(NSColor*)colorWithHexColorString:(NSString*)inColorString alpha:(float)alpha{
    NSColor* result = nil;
    unsigned colorCode = 0;
    unsigned char redByte, greenByte, blueByte;

    if (nil != inColorString)
    {
        NSScanner* scanner = [NSScanner scannerWithString:inColorString];
        (void) [scanner scanHexInt:&colorCode]; // ignore error
    }
    redByte = (unsigned char)(colorCode >> 16);
    greenByte = (unsigned char)(colorCode >> 8);
    blueByte = (unsigned char)(colorCode); // masks off high bits

    result = [NSColor colorWithCalibratedRed:(CGFloat)redByte / 0xff
                                       green:(CGFloat)greenByte / 0xff
                                        blue:(CGFloat)blueByte / 0xff
                                       alpha:alpha];
    return result;
}
@end
