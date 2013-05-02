//
//  EDElement.m
//  GraphPouch
//
//  Created by PATRICK LEE on 8/17/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDElement.h"
#import "EDCoreDataUtility+Worksheet.h"


@implementation EDElement

@dynamic zIndex;
@dynamic selected;
@dynamic locationX;
@dynamic locationY;
@dynamic elementWidth;
@dynamic elementHeight;
@dynamic page;

- (void)copyAttributes:(EDElement *)source{
    [self setZIndex:[source zIndex]];
    [self setSelected:[source selected]];
    [self setLocationX:[source locationX]];
    [self setLocationY:[source locationY]];
    [self setElementWidth:[source elementWidth]];
    [self setElementHeight:[source elementHeight]];
}

#warning need to move 'page' relationships to EDElement instead of individual worksheet elements
- (void)moveZIndexBack:(EDPage *)page{
    int increment = 0;
    // get selected elements
    NSMutableArray *selectedElements = [EDCoreDataUtility getAllSelectedWorksheetElementsOnPage:page context:[self managedObjectContext]];
    
    // add self too, even if not selected
    if (![self selected])
        [selectedElements addObject:self];
    
    // get all elements on page
    NSMutableArray *unselectedElements = [EDCoreDataUtility getAllUnselectedWorksheetElementsOnPage:page context:[self managedObjectContext]];
    
    // remove self if in the unselected array
    if ([unselectedElements containsObject:self]){
        [unselectedElements removeObject:self];
    }
    
    //NSLog(@"==before unselected elements:%@ selected:%@", unselectedElements, selectedElements);
    for (EDElement *unselectedElement in unselectedElements){
        // find out how many selected elements are greater than this element, then increment the value
        increment = 0;
        for (EDElement *selectedElement in selectedElements){
            if ([[selectedElement zIndex] intValue] > [[unselectedElement zIndex] intValue]){
                increment++;
            }
        }
        
        // increment z-index
        [unselectedElement setZIndex:[NSNumber numberWithInt:[[unselectedElement zIndex] intValue]+increment]];
        //NSLog(@"decrementing unselected element:%@ by:%d", unselectedElement, decrement);
    }
    
    // iterate through selected elements and number then
    int newZIndex = 1;
    
    for (EDElement *selectedElement in selectedElements){
        [selectedElement setZIndex:[NSNumber numberWithInt:newZIndex]];
        newZIndex++;
    }
    //NSLog(@"==after unselected elements:%@ selected:%@ increment:%d", unselectedElements, selectedElements, increment);
}

- (void)moveZIndexBackward:(EDPage *)page{
    // get selected elements
    NSMutableArray *selectedElements = [EDCoreDataUtility getAllSelectedWorksheetElementsOnPage:page context:[self managedObjectContext]];
    
    // add self too, even if not selected
    if (![self selected])
        [selectedElements addObject:self];
    
    // get all elements on page
    NSMutableArray *unselectedElements = [EDCoreDataUtility getAllUnselectedWorksheetElementsOnPage:page context:[self managedObjectContext]];
    
    // remove self if in the unselected array
    if ([unselectedElements containsObject:self])
        [unselectedElements removeObject:self];
    
    EDElement *neighborElement;
    for (EDElement *selectedElement in selectedElements){
        neighborElement = [EDCoreDataUtility getElementOnPage:page context:[self managedObjectContext] withZIndex:[[selectedElement zIndex] intValue]-1];
        // if neighbor element is not in the selected elements, and is not nil then we can increment the selected element and decrement the neighbor
        if ((![selectedElements containsObject:neighborElement]) && (neighborElement != nil)){
            [selectedElement setZIndex:[NSNumber numberWithInt:[[selectedElement zIndex] intValue]-1]];
            [neighborElement setZIndex:[NSNumber numberWithInt:[[neighborElement zIndex] intValue]+1]];
        }
    }
}

- (void)moveZIndexForward:(EDPage *)page{
    // get selected elements
    NSMutableArray *selectedElements = [EDCoreDataUtility getAllSelectedWorksheetElementsOnPage:page context:[self managedObjectContext]];
    
    // add self too, even if not selected
    if (![self selected])
        [selectedElements addObject:self];
    
    // get all elements on page
    NSMutableArray *unselectedElements = [EDCoreDataUtility getAllUnselectedWorksheetElementsOnPage:page context:[self managedObjectContext]];
    
    // remove self if in the unselected array
    if ([unselectedElements containsObject:self])
        [unselectedElements removeObject:self];
    
    EDElement *neighborElement;
    for (EDElement *selectedElement in selectedElements){
        neighborElement = [EDCoreDataUtility getElementOnPage:page context:[self managedObjectContext] withZIndex:[[selectedElement zIndex] intValue]+1];
        // if neighbor element is not in the selected elements, and is not nil then we can increment the selected element and decrement the neighbor
        if ((![selectedElements containsObject:neighborElement]) && (neighborElement != nil)){
            [selectedElement setZIndex:[NSNumber numberWithInt:[[selectedElement zIndex] intValue]+1]];
            [neighborElement setZIndex:[NSNumber numberWithInt:[[neighborElement zIndex] intValue]-1]];
        }
    }
}

- (void)moveZIndexFront:(EDPage *)page{
    int decrement = 0;
    // get selected elements
    NSMutableArray *selectedElements = [EDCoreDataUtility getAllSelectedWorksheetElementsOnPage:page context:[self managedObjectContext]];
    
    // add self too, even if not selected
    if (![self selected])
        [selectedElements addObject:self];
    
    // get all elements on page
    NSMutableArray *unselectedElements = [EDCoreDataUtility getAllUnselectedWorksheetElementsOnPage:page context:[self managedObjectContext]];
    
    // remove self if in the unselected array
    if ([unselectedElements containsObject:self]){
        [unselectedElements removeObject:self];
    }
    
    for (EDElement *unselectedElement in unselectedElements){
        // find out how many selected elements are lower than this element, then decrement the value
        decrement = 0;
        for (EDElement *selectedElement in selectedElements){
            if ([[selectedElement zIndex] intValue] < [[unselectedElement zIndex] intValue]){
                decrement++;
            }
        }
        
        // decrement z-index
        [unselectedElement setZIndex:[NSNumber numberWithInt:[[unselectedElement zIndex] intValue]-decrement]];
        //NSLog(@"decrementing unselected element:%@ by:%d", unselectedElement, decrement);
    }
    
    // iterate through selected elements and number then
    int increment = (int)[unselectedElements count]+1;
    
    for (EDElement *selectedElement in selectedElements){
        [selectedElement setZIndex:[NSNumber numberWithInt:increment]];
        increment++;
    }
}

- (void)setZIndexAfterInsert:(EDPage *)page{
    // get current max
    int currentMax = [EDCoreDataUtility getMaxZIndexOnPage:page context:[self managedObjectContext] doesNotMatch:self];
    [self setZIndex:[NSNumber numberWithInt:currentMax+1]];
    NSLog(@"setting z index for new element to:%d", [[self zIndex] intValue]);
}
@end
