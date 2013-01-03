//
//  EDEquationView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 1/2/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDEquation.h"
#import "EDGraph.h"

@interface EDEquationView : NSView{
    EDEquation *_equation;
    NSDictionary *_infoVertical;
    NSDictionary *_infoHorizontal;
    NSDictionary *_infoOrigin;
    EDGraph *_graph;
    NSManagedObjectContext *_context;
}

- (id)initWithFrame:(NSRect)frame equation:(EDEquation *)equation;
- (void)setGraphOrigin:(NSDictionary *)originInfo verticalInfo:(NSDictionary *)verticalInfo horizontalInfo:(NSDictionary *)horizontalInfo graph:(EDGraph *)graph context:(NSManagedObjectContext *)context;
    
@end
