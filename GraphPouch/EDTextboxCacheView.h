//
//  EDTextboxCacheView.h
//  GraphPouch
//
//  Created by PATRICK LEE on 6/30/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDTextboxView.h"

@interface EDTextboxCacheView : EDTextboxView{
    NSImage *_image;
}

- (id)initWithFrame:(NSRect)frame textboxModel:(EDTextbox *)myTextbox drawSelection:(BOOL)drawSelection image:(NSImage *)image;
    
@end
