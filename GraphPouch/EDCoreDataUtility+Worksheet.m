//
//  EDCoreDataUtility+Worksheet.m
//  GraphPouch
//
//  Created by PATRICK LEE on 1/12/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDCoreDataUtility.h"
#import "EDCoreDataUtility+Pages.h"
#import "EDCoreDataUtility+Worksheet.h"
#import "EDElement.h"
#import "EDEquation.h"
#import "EDGraph.h"
#import "EDLine.h"
#import "EDPage.h"
#import "EDTextbox.h"
#import "EDToken.h"
#import "NSManagedObject+EasyFetching.h"
#import "NSManagedObjectContext+Objects.h"
#import "NSMutableArray+EDPoint.h"
#import "NSObject+Document.h"

@implementation EDCoreDataUtility (Worksheet)

+ (void)selectAllWorksheetElementsOnCurrentPage:(NSManagedObjectContext *)context{
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:context];
    NSArray *objects = [currentPage getAllWorksheetObjects];
    
    for (EDElement *element in objects){
        // set every element as selected
        [element setSelected:TRUE];
    }
}

+ (void)selectNextWorksheetElementOnCurrentPage:(NSManagedObjectContext *)context{
    // get all selected objects on current page
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:context];
    NSArray *selectedObjects = [currentPage getAllSelectedWorksheetObjects];
    NSArray *allObjects = [currentPage getAllWorksheetObjects];
    if (([selectedObjects count] > 1) || ([selectedObjects count] == 0)){
        // clear selection of all objects
        [self deselectAllSelectedWorksheetElementsOnCurrentPage:context];
        
        // select the first object in the page
        [(EDElement *)[allObjects objectAtIndex:0] setSelected:TRUE];
    }
    else{
        //get index of currently selected object then get the next object
        EDElement *matchingObject = (EDElement *)[selectedObjects objectAtIndex:0];
        int i=0, j=0;
        for (EDElement *element in allObjects){
            if (element == matchingObject)
                break;
            
            i++;
        }
        
        // clear selection
        [self deselectAllSelectedWorksheetElementsOnCurrentPage:context];
        
        // match the very next object
        i++;
        // wrap-around
        if (i == [allObjects count]){
            // clear selection of all objects
            [self deselectAllSelectedWorksheetElementsOnCurrentPage:context];
            
            // select the first object in the page
            [(EDElement *)[allObjects objectAtIndex:0] setSelected:TRUE];
        }
        else{
            // select the very next element in the array
            for (EDElement *element in allObjects){
                // match the next element
                if (j == i){
                    [element setSelected:TRUE];
                    break;
                }
                
                j++;
            }
        }
    }
    
    // save
    //[EDCoreDataUtility save:context];
}

+ (void)selectPreviousWorksheetElementOnCurrentPage:(NSManagedObjectContext *)context{
    // get all selected objects on current page
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:context];
    NSArray *selectedObjects = [currentPage getAllSelectedWorksheetObjects];
    NSArray *allObjects = [currentPage getAllWorksheetObjects];
    if (([selectedObjects count] > 1) || ([selectedObjects count] == 0)){
        // clear selection of all objects
        [self deselectAllSelectedWorksheetElementsOnCurrentPage:context];
        
        // select the first object in the page
        [(EDElement *)[allObjects objectAtIndex:0] setSelected:TRUE];
    }
    else{
        //get index of currently selected object then get the next object
        EDElement *matchingObject = (EDElement *)[selectedObjects objectAtIndex:0];
        int i=0, j=0;
        for (EDElement *element in allObjects){
            if (element == matchingObject)
                break;
            
            i++;
        }
        
        // clear selection
        [self deselectAllSelectedWorksheetElementsOnCurrentPage:context];
        
        // match the previous object
        i--;
        
        // wrap-around
        if (i == -1){
            // clear selection of all objects
            [self deselectAllSelectedWorksheetElementsOnCurrentPage:context];
            
            // select the first object in the page
            [(EDElement *)[allObjects lastObject] setSelected:TRUE];
        }
        else{
            // select the very next element in the array
            for (EDElement *element in allObjects){
                // match the next element
                if (j == i){
                    [element setSelected:TRUE];
                    break;
                }
                
                j++;
            }
        }
    }
}

#pragma mark worksheet
+ (NSMutableArray *)copySelectedWorksheetElementsFromContext:(NSManagedObjectContext *)context toContext:(NSManagedObjectContext *)copyContext{
    // copy all selected objects
    NSMutableArray *allObjects = [[NSMutableArray alloc] init];
    
#warning worksheet elements
    NSArray *fetchedGraphs = [EDGraph getAllSelectedObjects:context];
    NSArray *fetchedLines = [EDLine getAllSelectedObjects:context];
    NSArray *fetchedTextboxes = [EDTextbox getAllSelectedObjects:context];
    NSMutableArray *fetchedObjects = [[NSMutableArray alloc] init];
    [fetchedObjects addObjectsFromArray:fetchedGraphs];
    [fetchedObjects addObjectsFromArray:fetchedLines];
    [fetchedObjects addObjectsFromArray:fetchedTextboxes];
    
    id copiedObject = nil;
    
    for (EDElement *element in fetchedObjects){
        // prototype
        copiedObject = [context copyObject:element toContext:copyContext parent:EDEntityNamePage];
        
        [allObjects addObject:copiedObject];
    }
    
    return allObjects;
}

+ (NSMutableArray *)getAllSelectedWorksheetElements:(NSManagedObjectContext *)context{
    // gets all selected objects
    NSMutableArray *allObjects = [[NSMutableArray alloc] init];
    NSArray *fetchedGraphs = [EDGraph getAllSelectedObjects:context];
    NSArray *fetchedLines = [EDLine getAllSelectedObjects:context];
    NSArray *fetchedTextboxes = [EDTextbox getAllSelectedObjects:context];
    
#warning worksheet elements
    [allObjects addObjectsFromArray:fetchedGraphs];
    [allObjects addObjectsFromArray:fetchedLines];
    [allObjects addObjectsFromArray:fetchedTextboxes];
    
    return allObjects;
}

+ (NSArray *)insertWorksheetElements:(NSArray *)elements intoContext:(NSManagedObjectContext *)context{
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:context];
    NSMutableArray *insertedObjects = [[NSMutableArray alloc] init];
    //EDElement *newElement;
    // insert objects into context
    for (EDElement *element in elements){
#warning worksheet elements
        // set element to this page
        if ([element isKindOfClass:[EDGraph class]]){
            EDGraph *newGraph = (EDGraph *)[context copyObject:element toContext:context parent:EDEntityNamePage];
            [newGraph setPage:currentPage];
            [insertedObjects addObject:newGraph];
        }
        else if ([element isKindOfClass:[EDLine class]]){
            // copying from copy context to document child context
            EDLine *newLine = (EDLine *)[context copyObject:element toContext:context parent:EDEntityNamePage];
            [newLine setPage:currentPage];
            [insertedObjects addObject:newLine];
        }
        else if ([element isKindOfClass:[EDTextbox class]]){
            // copying from copy context to document child context
            EDTextbox *newTextbox = (EDTextbox *)[context copyObject:element toContext:context parent:EDEntityNamePage];
            [newTextbox setPage:currentPage];
            [insertedObjects addObject:newTextbox];
        }
    }
    
    return insertedObjects;
}

+ (NSMutableArray *)getAllWorksheetElementsOnPage:(EDPage *)currentPage context:(NSManagedObjectContext *)context{
    // gets all selected objects
    NSMutableArray *allObjects = [[NSMutableArray alloc] init];
    NSArray *fetchedGraphs = [EDGraph getAllObjectsOnPage:currentPage context:context];
    NSArray *fetchedLines = [EDLine getAllObjectsOnPage:currentPage context:context];
    NSArray *fetchedTextboxes = [EDTextbox getAllObjectsOnPage:currentPage context:context];
    
    if (fetchedGraphs)
        [allObjects addObjectsFromArray:fetchedGraphs];
    
    if (fetchedLines)
        [allObjects addObjectsFromArray:fetchedLines];
    
    if (fetchedTextboxes)
        [allObjects addObjectsFromArray:fetchedTextboxes];
    
    return allObjects;
}

+ (NSMutableDictionary *)getAllTypesOfSelectedWorksheetElements:(NSManagedObjectContext *)context{
    // this method returns a dictionary of the types of selected objects
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    NSArray *graphObjects, *lineObjects, *textboxObjects;
    
#warning worksheet elements
    // get all selected graphs
    graphObjects = [EDGraph getAllSelectedObjects:context];
    lineObjects = [EDLine getAllSelectedObjects:context];
    textboxObjects = [EDTextbox getAllSelectedObjects:context];
    
    if (([textboxObjects count] > 0) && ([lineObjects count] > 0) && ([graphObjects count] > 0)) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDKeyGraphLineTextbox];
    }
    else if (([lineObjects count] > 0) && ([graphObjects count] > 0)) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDKeyGraphLine];
    }
    else if (([textboxObjects count] > 0) && ([graphObjects count] > 0)) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDKeyGraphTextbox];
    }
    else if (([textboxObjects count] > 0) && ([lineObjects count] > 0)) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDKeyLineTextbox];
    }
    else if ([graphObjects count] > 0) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDKeyGraph];
    }
    else if ([lineObjects count] > 0) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDKeyLine];
    }
    else if ([textboxObjects count] > 0) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDKeyTextbox];
    }
    
    
    return results;
}

+ (void)deselectAllSelectedWorksheetElementsOnCurrentPage:(NSManagedObjectContext *)context selectElement:(EDElement *)element{
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:context];
    NSArray *fetchedObjects = [currentPage getAllWorksheetObjects];
    if (fetchedObjects == nil) {
        // Handle the error
    }
    else{
        for (EDGraph *elem in fetchedObjects){
            [elem setSelected:FALSE];
        }
    }
    
    // select current element
    [element setSelected:TRUE];
}

+ (void)deselectAllSelectedWorksheetElementsOnCurrentPage:(NSManagedObjectContext *)context{
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:context];
    NSArray *fetchedObjects = [currentPage getAllWorksheetObjects];
    if (fetchedObjects == nil) {
        // Handle the error
    }
    else{
        for (EDGraph *elem in fetchedObjects){
            [elem setSelected:FALSE];
        }
    }
}

+ (void)deleteWorksheetElement:(EDElement *)element context:(NSManagedObjectContext *)context{
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:context];
#warning worksheet elements
    if ([element isKindOfClass:[EDGraph class]]) {
        [currentPage removeGraphsObject:(EDGraph *)element];
    }
    else if ([element isKindOfClass:[EDLine class]]) {
        [currentPage removeLinesObject:(EDLine *)element];
    }
    else if ([element isKindOfClass:[EDTextbox class]]) {
        [currentPage removeTextboxesObject:(EDTextbox *)element];
    }
    [context deleteObject:element];
}

+ (void)deleteSelectedWorksheetElements:(NSManagedObjectContext *)context{
    NSMutableArray *selectedElements = [self getAllSelectedWorksheetElements:context];
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:context];
    
    for (EDElement *element in selectedElements){
#warning worksheet elements
        if ([element isKindOfClass:[EDGraph class]]) {
            [currentPage removeGraphsObject:(EDGraph *)element];
        }
        else if ([element isKindOfClass:[EDLine class]]) {
            [currentPage removeLinesObject:(EDLine *)element];
        }
        else if ([element isKindOfClass:[EDTextbox class]]) {
            [currentPage removeTextboxesObject:(EDTextbox *)element];
        }
        [context deleteObject:element];
    }
}

+ (void)moveSelectedWorksheetElements:(EDDirection)direction multiplyModifier:(BOOL)modifier context:(NSManagedObjectContext *)context{
    float increment;
    if (modifier){
        if ((direction == EDDirectionDown) || (direction == EDDirectionRight)){
            increment = EDIncrementPressedArrowModifier;
        }
        else{
            increment = -1 * EDIncrementPressedArrowModifier;
        }
    }
    else{
        if ((direction == EDDirectionDown) || (direction == EDDirectionRight)){
            increment = EDIncrementPressedArrow;
        }
        else{
            increment = -1 * EDIncrementPressedArrow;
        }
    }
    
    NSMutableArray *selectedElements = [self getAllSelectedWorksheetElements:context];
    for (EDElement *element in selectedElements){
        if ((direction == EDDirectionRight) || (direction == EDDirectionLeft)){
            [element setLocationX:([element locationX] + increment)];
        }
        else{
            [element setLocationY:([element locationY] + increment)];
        }
    }
}

+ (void)selectElementsInRect:(NSRect)rect context:(NSManagedObjectContext *)context{
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:context];
    NSArray *objects = [currentPage getAllWorksheetObjects];
    NSRect elementRect;
    BOOL intersectionRect, changed = FALSE;
    // iterate through all objects
    for (EDElement *element in objects){
        // create rect for element
        elementRect = NSMakeRect([element locationX], [element locationY], [element elementWidth], [element elementHeight]);
        
        intersectionRect = NSIntersectsRect(rect, elementRect);
        if(intersectionRect){
            // set element as selected
            if (![element selected]){
                changed = TRUE;
                [element setSelected:TRUE];
            }
        }
        else{
            if ([element selected]){
                changed = TRUE;
                [element setSelected:FALSE];
            }
        }
    }
    
    //if there was a change then save
    if (changed)
        [EDCoreDataUtility saveContext:context];
}
@end
