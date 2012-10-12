//
//  EDPage.m
//  GraphPouch
//
//  Created by PATRICK LEE on 10/2/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPage.h"
#import "EDConstants.h"
#import "EDCoreDataUtility.h"

@implementation EDPage

@dynamic currentPage;
@dynamic pageNumber;
@dynamic selected;

- (id)initWithCoder:(NSCoder *)aDecoder{
    EDCoreDataUtility *coreData = [EDCoreDataUtility sharedCoreDataUtility];
    
    // create page object, but don't insert it into context
    self = [[EDPage alloc] initWithEntity:[NSEntityDescription entityForName:EDEntityNamePage inManagedObjectContext:[coreData context]] insertIntoManagedObjectContext:nil];
    
    // init rest of attributes
    if(self){
        [self setCurrentPage:[[NSNumber alloc] initWithBool:[aDecoder decodeBoolForKey:EDPageAttributeCurrent]]];
        [self setSelected:[[NSNumber alloc] initWithBool:[aDecoder decodeBoolForKey:EDPageAttributeSelected]]];
        [self setPageNumber:[[NSNumber alloc] initWithInt:[aDecoder decodeInt32ForKey:EDPageAttributePageNumber]]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeBool:[[self currentPage] boolValue] forKey:EDPageAttributeCurrent];
    [aCoder encodeBool:[[self selected] boolValue] forKey:EDPageAttributeSelected];
    [aCoder encodeInt64:[[self pageNumber] intValue] forKey:EDPageAttributePageNumber];
}
@end
