//
//  EDPanelPropertiesTextViewController.m
//  GraphPouch
//
//  Created by PATRICK LEE on 2/9/13.
//  Copyright (c) 2013 Patrick Lee. All rights reserved.
//

#import "EDPanelPropertiesTextViewController.h"
#import "EDConstants.h"

@interface EDPanelPropertiesTextViewController ()

@end

@implementation EDPanelPropertiesTextViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)initWindowAfterLoaded:(NSManagedObjectContext *)context{
    [super initWindowAfterLoaded:context];
}

- (void)initButtons:(EDTextView *)textView{
    _currentTextView = textView;
    /*
    NSRange effectiveRange, range;
    id attrValue;
    for (int indexRange = 0; indexRange < [[_currentTextView selectedRanges] count]; indexRange++){
        [[[_currentTextView selectedRanges] objectAtIndex:indexRange] getValue:&range];
        attrValue = [[_currentTextView textStorage] attribute:NSSuperscriptAttributeName atIndex:range.location effectiveRange:&effectiveRange];
        NSLog(@"attr value:%@", attrValue);
    }*/
}

#pragma mark buttons
- (IBAction)onButtonPressedBold:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventButtonPressedBold object:self];
}

- (void)updateButtonStates{
    NSLog(@"need to update button state");
    NSRange effectiveRange, range;
    id attrValue;
    for (int indexRange = 0; indexRange < [[_currentTextView selectedRanges] count]; indexRange++){
        [[[_currentTextView selectedRanges] objectAtIndex:indexRange] getValue:&range];
        attrValue = [[_currentTextView textStorage] attribute:NSSuperscriptAttributeName atIndex:range.location effectiveRange:&effectiveRange];
        NSLog(@"attr value:%@ range loc:%ld length:%ld", attrValue, effectiveRange.location, effectiveRange.length);
    }
}
@end
