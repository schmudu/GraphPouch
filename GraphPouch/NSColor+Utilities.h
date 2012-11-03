//
//  NSColor+Utilities.h
//  GraphPouch
//
//  Created by PATRICK LEE on 9/14/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSColor (Utilities)
+(NSColor*)colorWithHexColorString:(NSString*)inColorString;
+(NSColor*)colorWithHexColorString:(NSString*)inColorString alpha:(float)alpha;
@end
