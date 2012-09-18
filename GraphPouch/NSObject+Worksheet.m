//
//  NSObject+Worksheet.m
//  GraphPouch
//
//  Created by PATRICK LEE on 9/18/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "NSObject+Worksheet.h"
#import "EDWorksheetElementView.h"

@implementation NSObject (Worksheet)

- (BOOL)isWorksheetElement{
    return [[self class] isSubclassOfClass:[EDWorksheetElementView class]];
}

@end
