//
//  EDCoreDataUtility.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/30/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility.h"
#import "EDConstants.h"

@interface EDCoreDataUtility()
@end

@implementation EDCoreDataUtility
+ (NSMutableDictionary *)createContext:(NSManagedObjectContext *)startContext{
    NSMutableDictionary *contexts = [[NSMutableDictionary alloc] init];
    // this method will create a child context that will be used throught the program
    // this is so the nspersistentdocumentcontroller won't complain when we save
    NSManagedObjectContext *rootContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    //NSManagedObjectContext *rootContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    [rootContext setPersistentStoreCoordinator:[startContext persistentStoreCoordinator]];
    NSManagedObjectContext *childContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    // set root as parent
    [childContext setParentContext:rootContext];
    
    // set undo
    [rootContext setUndoManager:[startContext undoManager]];
    
    [contexts setObject:childContext forKey:EDKeyContextChild];
    [contexts setObject:rootContext forKey:EDKeyContextRoot];
    
    return contexts;
}


+ (BOOL)save:(NSManagedObjectContext *)context{
    NSLog(@"===saving context:%@", context);
    NSError *error;
    if (![context save:&error]) {
        // If Cocoa generated the error...
        //NSString *message = nil;
        if ([[error domain] isEqualToString:@"NSCocoaErrorDomain"]) {
            // ...check whether there's an NSDetailedErrors array
            NSDictionary *userInfo = [error userInfo];
            if ([userInfo valueForKey:@"NSDetailedErrors"] != nil) {
                // ...and loop through the array, if so.
                NSArray *errors = [userInfo valueForKey:@"NSDetailedErrors"];
                for (NSError *anError in errors) {
                    
                    NSDictionary *subUserInfo = [anError userInfo];
                    subUserInfo = [anError userInfo];
                    // Granted, this indents the NSValidation keys rather a lot
                    // ...but it's a small loss to keep the code more readable.
                    NSLog(@"Core Data Save Error\n\n \
                          NSValidationErrorKey\n%@\n\n \
                          NSValidationErrorPredicate\n%@\n\n \
                          NSValidationErrorObject\n%@\n\n \
                          NSLocalizedDescription\n%@",
                          [subUserInfo valueForKey:@"NSValidationErrorKey"],
                          [subUserInfo valueForKey:@"NSValidationErrorPredicate"],
                          [subUserInfo valueForKey:@"NSValidationErrorObject"],
                          [subUserInfo valueForKey:@"NSLocalizedDescription"]);
                }
            }
            // If there was no NSDetailedErrors array, print values directly
            // from the top-level userInfo object. (Hint: all of these keys
            // will have null values when you've got multiple errors sitting
            // behind the NSDetailedErrors key.
            else {
                NSLog(@"Core Data Save Error\n\n \
                      NSValidationErrorKey\n%@\n\n \
                      NSValidationErrorPredicate\n%@\n\n \
                      NSValidationErrorObject\n%@\n\n \
                      NSLocalizedDescription\n%@",
                      [userInfo valueForKey:@"NSValidationErrorKey"],
                      [userInfo valueForKey:@"NSValidationErrorPredicate"],
                      [userInfo valueForKey:@"NSValidationErrorObject"],
                      [userInfo valueForKey:@"NSLocalizedDescription"]);
                
            }
        }
        // Handle mine--or 3rd party-generated--errors
        else {
            NSLog(@"Custom Error: %@", [error localizedDescription]);
        }
        return NO;
    }
    return YES;
}
/*
+ (void)save:(NSManagedObjectContext *)context{
    NSError *error;
    BOOL successfulSave = [context save:&error];
    if (!successfulSave) {
        NSLog(@"error:%@, %@", error, [error userInfo]);
    }
}*/

+ (NSManagedObject *)getObject:(NSManagedObject *)object context:(NSManagedObjectContext *)context{
    // this method returns the page object that matches the page number
    NSArray *fetchedObjects;
    
    NSPredicate *searchFilter = [NSPredicate predicateWithFormat:@"(SELF == %@)", object];
    NSArray *filteredResults = [fetchedObjects filteredArrayUsingPredicate:searchFilter];;
    return [filteredResults objectAtIndex:0];
}

@end
