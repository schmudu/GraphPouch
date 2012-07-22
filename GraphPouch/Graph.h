//
//  Graph.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/22/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Graph : NSManagedObject

@property (nonatomic, retain) NSNumber * hasGridLines;
@property (nonatomic, retain) NSNumber * hasTickMarks;

@end
