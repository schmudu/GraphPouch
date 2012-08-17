//
//  EDElement.h
//  GraphPouch
//
//  Created by PATRICK LEE on 8/17/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EDElement : NSManagedObject

//@property (nonatomic, retain) NSNumber * selected;
//@property (nonatomic, retain) NSNumber * locationX;
//@property (nonatomic, retain) NSNumber * locationY;

@property float locationX, locationY;
@property BOOL selected;
@end
