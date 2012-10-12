//
//  EDPage.h
//  GraphPouch
//
//  Created by PATRICK LEE on 10/2/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EDPage : NSManagedObject <NSCoding>

@property (nonatomic, retain) NSNumber * currentPage;
@property (nonatomic, retain) NSNumber * pageNumber;
@property (nonatomic, retain) NSNumber * selected;

@end
