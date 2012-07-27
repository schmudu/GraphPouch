//
//  EDWorksheetElementView.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/26/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import "EDWorksheetElementView.h"

@implementation EDWorksheetElementView
@synthesize viewID;

+ (NSString *)generateID{
    NSDate *now = [[NSDate alloc] init];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyyMMDDHHmmssA"];
    NSString *dateString = [format stringFromDate:now];
    NSString *returnStr = [[[NSString alloc] initWithFormat:@"element"] stringByAppendingString:dateString];
    //NSLog(@"creating id of: %@", returnStr);
    return returnStr;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
}

@end
