//
//  EDGraph.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/22/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+EasyFetching.h"

@interface EDGraph : NSManagedObject

@property NSString *equation;
@property int hasTickMarks, hasGridLines, selected;
@property float locationX, locationY;
@end
