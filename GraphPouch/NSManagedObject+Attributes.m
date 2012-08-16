//
//  NSManagedObject+Attributes.m
//  GraphPouch
//
//  Created by PATRICK LEE on 8/15/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "NSManagedObject+Attributes.h"

@implementation NSManagedObject (Attributes)

- (BOOL)isSelectedElement{
    //if ([[self valueForKey:@"selected"] isEqualToNumber:[[NSNumber alloc] initWithBool:TRUE]]){
    if ([[self valueForKey:@"selected"] boolValue] == TRUE){
        return true;
    }
    else {
        return false;
    }
}
@end