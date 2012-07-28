//
//  EDPropertiesViewControllerText.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/27/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDPropertiesViewControllerText.h"

@interface EDPropertiesViewControllerText ()

@end

@implementation EDPropertiesViewControllerText

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:@"EDPropertiesViewText" bundle:nibBundleOrNil];
    if (self) {
        [self setTitle:@"Text Properties"];
    }
    
    return self;
}

@end
