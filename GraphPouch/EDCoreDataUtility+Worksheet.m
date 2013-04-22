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
#import "EDExpression.h"
#import "EDGraph.h"
#import "EDImage.h"
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
    NSArray *fetcheExpressions = [EDExpression getAllSelectedObjects:context];
    NSArray *fetchedGraphs = [EDGraph getAllSelectedObjects:context];
    NSArray *fetchedImages = [EDImage getAllSelectedObjects:context];
    NSArray *fetchedLines = [EDLine getAllSelectedObjects:context];
    NSArray *fetchedTextboxes = [EDTextbox getAllSelectedObjects:context];
    NSMutableArray *fetchedObjects = [[NSMutableArray alloc] init];
    [fetchedObjects addObjectsFromArray:fetcheExpressions];
    [fetchedObjects addObjectsFromArray:fetchedGraphs];
    [fetchedObjects addObjectsFromArray:fetchedImages];
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
    NSArray *fetchedExpressions = [EDExpression getAllSelectedObjects:context];
    NSArray *fetchedGraphs = [EDGraph getAllSelectedObjects:context];
    NSArray *fetchedImages = [EDImage getAllSelectedObjects:context];
    NSArray *fetchedLines = [EDLine getAllSelectedObjects:context];
    NSArray *fetchedTextboxes = [EDTextbox getAllSelectedObjects:context];
    
#warning worksheet elements
    [allObjects addObjectsFromArray:fetchedExpressions];
    [allObjects addObjectsFromArray:fetchedGraphs];
    [allObjects addObjectsFromArray:fetchedImages];
    [allObjects addObjectsFromArray:fetchedLines];
    [allObjects addObjectsFromArray:fetchedTextboxes];
    
    return allObjects;
}

+ (NSArray *)insertWorksheetElements:(NSArray *)elements intoContext:(NSManagedObjectContext *)context{
    EDPage *currentPage = [EDCoreDataUtility getCurrentPage:context];
    NSMutableArray *insertedObjects = [[NSMutableArray alloc] init];
    
    // insert objects into context
    for (EDElement *element in elements){
#warning worksheet elements
        // set element to this page
        if ([element isKindOfClass:[EDExpression class]]){
            EDExpression *newExpression = (EDExpression *)[context copyObject:element toContext:context parent:EDEntityNameExpression];
            [newExpression setPage:currentPage];
            [insertedObjects addObject:newExpression];
        }
        else if ([element isKindOfClass:[EDGraph class]]){
            EDGraph *newGraph = (EDGraph *)[context copyObject:element toContext:context parent:EDEntityNamePage];
            [newGraph setPage:currentPage];
            [insertedObjects addObject:newGraph];
        }
        else if ([element isKindOfClass:[EDImage class]]){
            EDImage *newImage = (EDImage *)[context copyObject:element toContext:context parent:EDEntityNamePage];
            [newImage setPage:currentPage];
            [insertedObjects addObject:newImage];
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
#warning worksheet elements
    NSMutableArray *allObjects = [[NSMutableArray alloc] init];
    NSArray *fetchedExpressions = [EDExpression getAllObjectsOnPage:currentPage context:context];
    NSArray *fetchedGraphs = [EDGraph getAllObjectsOnPage:currentPage context:context];
    NSArray *fetchedImages = [EDImage getAllObjectsOnPage:currentPage context:context];
    NSArray *fetchedLines = [EDLine getAllObjectsOnPage:currentPage context:context];
    NSArray *fetchedTextboxes = [EDTextbox getAllObjectsOnPage:currentPage context:context];
    
    if (fetchedExpressions)
        [allObjects addObjectsFromArray:fetchedExpressions];
    
    if (fetchedGraphs)
        [allObjects addObjectsFromArray:fetchedGraphs];
    
    if (fetchedImages)
        [allObjects addObjectsFromArray:fetchedImages];
    
    if (fetchedLines)
        [allObjects addObjectsFromArray:fetchedLines];
    
    if (fetchedTextboxes)
        [allObjects addObjectsFromArray:fetchedTextboxes];
    
    return allObjects;
}

+ (NSMutableDictionary *)getPanelType:(NSManagedObjectContext *)context{
    // this method returns the type of panel that needs to be shown
    // this method returns a dictionary of the types of selected objects
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    NSArray *expressionObjects, *graphObjects, *imageObjects, *lineObjects, *textboxObjects;
    
#warning worksheet elements
    // get all selected graphs
    expressionObjects = [EDExpression getAllSelectedObjects:context];
    graphObjects = [EDGraph getAllSelectedObjects:context];
    imageObjects = [EDImage getAllSelectedObjects:context];
    lineObjects = [EDLine getAllSelectedObjects:context];
    textboxObjects = [EDTextbox getAllSelectedObjects:context];
    
    /*
    if (([expressionObjects count] > 0) && ([textboxObjects count] > 0) && ([lineObjects count] > 0) && ([graphObjects count] > 0)) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDKeyExpressionGraphLineTextbox];
    }
    else if (([expressionObjects count] > 0) && ([textboxObjects count] > 0) && ([lineObjects count] > 0)) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDKeyExpressionLineTextbox];
    }
    else if (([expressionObjects count] > 0) && ([textboxObjects count] > 0) && ([graphObjects count] > 0)) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDKeyExpressionGraphTextbox];
    }
    else if (([expressionObjects count] > 0) && ([lineObjects count] > 0) && ([graphObjects count] > 0)) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDKeyExpressionGraphLine];
    }
    else if (([expressionObjects count] > 0) && ([graphObjects count] > 0)) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDKeyExpressionGraph];
    }
    else if (([expressionObjects count] > 0) && ([lineObjects count] > 0)) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDKeyExpressionLine];
    }
    else if (([expressionObjects count] > 0) && ([textboxObjects count] > 0)) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDKeyExpressionTextbox];
    }
    else if ([expressionObjects count] > 0) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDKeyExpression];
    }
    else if (([textboxObjects count] > 0) && ([lineObjects count] > 0) && ([graphObjects count] > 0)) {
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
     */
    if ([lineObjects count]>0){
        if(([expressionObjects count]>0) ||
           ([graphObjects count]>0) ||
           ([imageObjects count]>0) ||
           ([textboxObjects count]>0)){
            [results setValue:[NSNumber numberWithBool:TRUE] forKey:EDKeyBasicWithoutHeight];
        }
        else{
            // only lines
            [results setValue:[NSNumber numberWithBool:TRUE] forKey:EDKeyLine];
        }
    }
    else{
        // check for expressions
        if ([expressionObjects count]>0){
            if (([graphObjects count] > 0) ||
                ([imageObjects count] > 0) ||
                ([textboxObjects count] > 0)){
                [results setValue:[NSNumber numberWithBool:TRUE] forKey:EDKeyBasic];
            }
            else{
                // only expressions
                [results setValue:[NSNumber numberWithBool:TRUE] forKey:EDKeyExpression];
            }
        }
        else{
            // check for graphs
            if ([graphObjects count]>0){
                if (([imageObjects count]>0) ||
                    ([textboxObjects count]>0)){
                    [results setValue:[NSNumber numberWithBool:TRUE] forKey:EDKeyBasic];
                }
                else{
                    // only graphs
                    [results setValue:[NSNumber numberWithBool:TRUE] forKey:EDKeyGraph];
                }
            }
            else{
                if ([imageObjects count]>0){
                    if ([textboxObjects count]>0){
                        [results setValue:[NSNumber numberWithBool:TRUE] forKey:EDKeyBasic];
                    }
                    else{
                        // only textboxes
                        [results setValue:[NSNumber numberWithBool:TRUE] forKey:EDKeyImage];
                    }
                }
                else{
                    if ([textboxObjects count]>0){
                        [results setValue:[NSNumber numberWithBool:TRUE] forKey:EDKeyBasic];
                    }
                    else{
                        // nothing, add worksheets here
                    }
                }
            }
        }
    }
    
return results;
}

/*
+ (NSMutableDictionary *)getAllTypesOfSelectedWorksheetElements:(NSManagedObjectContext *)context{
    // this method returns a dictionary of the types of selected objects
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    NSArray *expressionObjects, *graphObjects, *imageObjects, *lineObjects, *textboxObjects;
    
#warning worksheet elements
    // get all selected graphs
    expressionObjects = [EDExpression getAllSelectedObjects:context];
    graphObjects = [EDGraph getAllSelectedObjects:context];
    imageObjects = [EDGraph getAllSelectedObjects:context];
    lineObjects = [EDLine getAllSelectedObjects:context];
    textboxObjects = [EDTextbox getAllSelectedObjects:context];
    
    if (([expressionObjects count] > 0) && ([textboxObjects count] > 0) && ([lineObjects count] > 0) && ([graphObjects count] > 0)) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDKeyExpressionGraphLineTextbox];
    }
    else if (([expressionObjects count] > 0) && ([textboxObjects count] > 0) && ([lineObjects count] > 0)) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDKeyExpressionLineTextbox];
    }
    else if (([expressionObjects count] > 0) && ([textboxObjects count] > 0) && ([graphObjects count] > 0)) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDKeyExpressionGraphTextbox];
    }
    else if (([expressionObjects count] > 0) && ([lineObjects count] > 0) && ([graphObjects count] > 0)) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDKeyExpressionGraphLine];
    }
    else if (([expressionObjects count] > 0) && ([graphObjects count] > 0)) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDKeyExpressionGraph];
    }
    else if (([expressionObjects count] > 0) && ([lineObjects count] > 0)) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDKeyExpressionLine];
    }
    else if (([expressionObjects count] > 0) && ([textboxObjects count] > 0)) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDKeyExpressionTextbox];
    }
    else if ([expressionObjects count] > 0) {
        [results setValue:[[NSNumber alloc] initWithBool:TRUE] forKey:EDKeyExpression];
    }
    else if (([textboxObjects count] > 0) && ([lineObjects count] > 0) && ([graphObjects count] > 0)) {
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
}*/

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
    if ([element isKindOfClass:[EDExpression class]]) {
        [currentPage removeExpressionsObject:(EDExpression *)element];
    }
    else if ([element isKindOfClass:[EDGraph class]]) {
        [currentPage removeGraphsObject:(EDGraph *)element];
    }
    else if ([element isKindOfClass:[EDImage class]]) {
        [currentPage removeImagesObject:(EDImage *)element];
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
        if ([element isKindOfClass:[EDExpression class]]) {
            [currentPage removeExpressionsObject:(EDExpression *)element];
        }
        else if ([element isKindOfClass:[EDGraph class]]) {
            [currentPage removeGraphsObject:(EDGraph *)element];
        }
        else if ([element isKindOfClass:[EDImage class]]) {
            [currentPage removeImagesObject:(EDImage *)element];
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
