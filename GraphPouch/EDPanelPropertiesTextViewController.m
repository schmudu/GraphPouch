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

- (void)initButtons:(EDTextView *)textView textbox:(EDTextbox *)textbox{
    _currentTextView = textView;
    _currentTextbox = textbox;
}

- (void)updateButtonStates{
    //NSLog(@"need to update button state");
    [self setUpFontButton];
}

- (NSDictionary *)getAttributeValueForSelectedRanges:(NSString *)attribute{
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    // set default of FALSE for diff
    [results setObject:[NSNumber numberWithBool:FALSE] forKey:EDKeyDiff];
    
    NSRange effectiveRange, range;
    id savedAttrValue = nil, attrValue = nil;
    // for each range get the attribute
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

#pragma mark button bold
- (IBAction)onButtonPressedBold:(id)sender{
    if (_currentTextView){
        NSArray *selectedRanges = [_currentTextView selectedRanges];
        NSMutableAttributedString *string = [_currentTextView textStorage];
        NSRange range;
        
        [string beginEditing];
        for (int rangeIndex=0; rangeIndex<[selectedRanges count]; rangeIndex++){
            [[selectedRanges objectAtIndex:rangeIndex] getValue:&range];
            //[string addAttribute:NSSuperscriptAttributeName value:[NSNumber numberWithInt:1] range:range];
            [string addAttribute:NSSuperscriptAttributeName value:[NSNumber numberWithInt:1] range:range];
        }
        [string endEditing];
        
        // save
        [_currentTextbox setTextValue:string];
    }
}

#pragma mark button fonts
- (IBAction)onButtonFontsSelected:(id)sender{
    NSRange effectiveRange, range;
    NSFont *oldFont = nil, *newFont = nil;
    
    // start editing
    [[_currentTextView textStorage] beginEditing];
    
    // for each range get the attribute and set the name
    for (int indexRange = 0; indexRange < [[_currentTextView selectedRanges] count]; indexRange++){
        [[[_currentTextView selectedRanges] objectAtIndex:indexRange] getValue:&range];
        oldFont = [[_currentTextView textStorage] attribute:NSFontAttributeName atIndex:range.location effectiveRange:&effectiveRange];
        
        // we now have the NSFont name, reset the font name
        newFont = [NSFont fontWithName:[[buttonFonts selectedItem] title] size:[oldFont pointSize]];
        
        // remove old
        [[_currentTextView textStorage] removeAttribute:NSFontAttributeName range:range];
        
        // add new
        [[_currentTextView textStorage] addAttribute:NSFontAttributeName value:newFont range:range];
    }
    
    // end editing
    [[_currentTextView textStorage] endEditing];
    
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


@end
