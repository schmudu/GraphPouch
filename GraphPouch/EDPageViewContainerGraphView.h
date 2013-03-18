//
//  EDPageViewContainerGraphView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 3/17/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDGraph.h"

@interface EDPageViewContainerGraphView : NSView{
    EDGraph *_graph;
    NSManagedObjectContext *_context;
}

- (id)initWithFrame:(NSRect)frame graph:(EDGraph *)graph context:(NSManagedObjectContext *)context;
@end
