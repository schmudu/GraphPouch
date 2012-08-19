//
//  EDGraphView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/22/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDWorksheetElementView.h"
@class EDGraph;

@interface EDGraphView : EDWorksheetElementView{
}
//@property (nonatomic, strong) EDGraph *graph;
//@property (nonatomic, strong) EDElement *graph;

- (id)initWithFrame:(NSRect)frame graphModel:(EDGraph *)myGraph;

@end
