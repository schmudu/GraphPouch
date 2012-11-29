//
//  EDEquation.h
//  GraphPouch
//
//  Created by PATRICK LEE on 11/29/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EDGraph;

@interface EDEquation : NSManagedObject <NSCoding>

@property (nonatomic, retain) NSString * equation;
@property BOOL showLabel;
@property BOOL isVisible;
@property (nonatomic, retain) EDGraph *graph;

@end
