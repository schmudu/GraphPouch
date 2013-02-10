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
- (void)setUpFontButton;
- (NSDictionary *)getAttributeValueForSelectedRanges:(NSString *)attribute;
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
    
    [self setUpFontButton];
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

#pragma mark button bold
- (IBAction)onButtonPressedBold:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:EDEventButtonPressedBold object:self];
}

#pragma mark button fonts
- (IBAction)onButtonFontsSelected:(id)sender{
    NSLog(@"a font was chosen");
}

- (void)setUpFontButton{
    NSString *fontName;
    
    // populate font button
    NSMutableArray *fontList = [[NSMutableArray alloc] initWithArray:[[NSFontManager sharedFontManager] availableFontFamilies]];
    [fontList sortUsingSelector:@selector(caseInsensitiveCompare:)];
    [buttonFonts removeAllItems];
    [buttonFonts addItemsWithTitles:fontList];
    
    NSDictionary *font = [self getAttributeValueForSelectedRanges:NSFontAttributeName];
    // if there is no difference in values and the font is set then set selected item
    if ((![[font objectForKey:EDKeyDiff] boolValue]) && ([font objectForKey:EDKeyValue] != nil)){
        fontName = [(NSFont *)[font objectForKey:EDKeyValue] fontName];
        
        // set selection
        [buttonFonts selectItemWithTitle:fontName];
    }
}


- (void)updateButtonStates{
    NSLog(@"need to update button state");
    [self setUpFontButton];
    /*
    NSRange effectiveRange, range;
    id attrValue;
    for (int indexRange = 0; indexRange < [[_currentTextView selectedRanges] count]; indexRange++){
        [[[_currentTextView selectedRanges] objectAtIndex:indexRange] getValue:&range];
        attrValue = [[_currentTextView textStorage] attribute:NSSuperscriptAttributeName atIndex:range.location effectiveRange:&effectiveRange];
        NSLog(@"attr value:%@ range loc:%ld length:%ld", attrValue, effectiveRange.location, effectiveRange.length);
    }*/
}

- (NSDictionary *)getAttributeValueForSelectedRanges:(NSString *)attribute{
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    [results setObject:[NSNumber numberWithBool:FALSE] forKey:EDKeyDiff];
    
    NSRange effectiveRange, range;
    id savedAttrValue = nil, attrValue = nil;
    for (int indexRange = 0; indexRange < [[_currentTextView selectedRanges] count]; indexRange++){
        [[[_currentTextView selectedRanges] objectAtIndex:indexRange] getValue:&range];
        attrValue = [[_currentTextView textStorage] attribute:attribute atIndex:range.location effectiveRange:&effectiveRange];
        
        // if value is not the same as the last value then there's a difference
        if ((savedAttrValue != nil) && (attrValue != nil) && (savedAttrValue != attrValue)){
            [results setObject:[NSNumber numberWithBool:TRUE] forKey:EDKeyDiff];
            return results;
        }
        
        [results setObject:attrValue forKey:EDKeyValue];
        savedAttrValue = attrValue;
    }
    return results;
}
@end
