//
//  NSManagedObjectContext+Objects.h
//  GraphPouch
//
//  Created by PATRICK LEE on 3/2/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Objects)
- (NSManagedObject*)copyObject:(NSManagedObject*)object toContext:(NSManagedObjectContext*)moc parent:(NSString*)parentEntity;
@end
