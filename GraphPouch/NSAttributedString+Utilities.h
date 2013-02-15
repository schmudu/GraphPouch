//
//  NSAttributedString+Utilities.h
//  GraphPouch
//
//  Created by PATRICK LEE on 2/15/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (Utilities)

- (BOOL)hasAttribute:(NSString *)attribute forRange:(NSRange)range;
@end
