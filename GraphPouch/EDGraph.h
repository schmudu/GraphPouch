//
//  EDGraph.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/22/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EDElement.h"
#import "NSManagedObject+EasyFetching.h"
#import "EDPage.h"

@interface EDGraph : EDElement <NSCoding>{
    // set as weak otherwise we'll have a cyclic cycle between the page and graphs
    //__weak EDPage *page;
}

@property NSString *equation;
@property EDPage *page;
@property BOOL hasTickMarks, hasGridLines;


/*
- (void)setPage:(EDPage *)newPage;
- (EDPage *)getPage;
 */
@end
