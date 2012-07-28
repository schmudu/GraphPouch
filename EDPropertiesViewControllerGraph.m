//
//  EDPropertiesViewControllerGraph.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/27/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPropertiesViewControllerGraph.h"

@interface EDPropertiesViewControllerGraph ()

@end

@implementation EDPropertiesViewControllerGraph

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"EDPropertiesViewGraph" bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@"Graph Properties"];
    }
    
    return self;
}

@end
