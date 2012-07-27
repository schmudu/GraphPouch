//
//  EDWorksheetElementView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 7/26/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EDWorksheetElementView : NSView{
    @protected
    NSNotificationCenter    *nc;
}
@property NSString *viewID;

+ (NSString *)generateID;


@end
