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
- (void)setUpFontSizeField;
- (void)setUpFontButton;
- (NSDictionary *)getAttributeValueForSelectedRanges:(NSString *)attribute;
- (NSDictionary *)getFontAttributeValueForSelectedRanges:(NSString *)attribute;
- (void)onFontSizeDidChange:(NSNotification *)note;
@end

@implementation EDPanelPropertiesTextViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _delegateFontSize = [[EDPanelPropertiesTextViewFontSizeText alloc] init];
        
        // listen
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFontSizeDidChange:) name:EDEventControlDidChange object:fieldFontSize];
    }
    
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:EDEventControlDidChange object:fieldFontSize];
}

- (void)initWindowAfterLoaded:(NSManagedObjectContext *)context{
    [super initWindowAfterLoaded:context];
    
    [fieldFontSize setDelegate:_delegateFontSize];
    
    [self setUpFontButton];
    [self setUpFontSizeField];
}

- (void)initButtons:(EDTextView *)textView textbox:(EDTextbox *)textbox{
    _currentTextView = textView;
    _currentTextbox = textbox;
}

- (void)updateButtonStates{
    [self setUpFontButton];
    [self setUpFontSizeField];
}

- (NSDictionary *)getFontAttributeValueForSelectedRanges:(NSString *)attribute{
    if (_currentTextView == nil){
        // do nothing
        return nil;
    }
    
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    // set default of FALSE for diff
    [results setObject:[NSNumber numberWithBool:FALSE] forKey:EDKeyDiff];
    
    NSRange range;
    __block NSFont *font;
    __block id savedAttrValue = nil, attrValue = nil;
    __block float flSavedAttrValue = -1, flAttrValue = -1;
    
    for (int indexRange = 0; indexRange < [[_currentTextView selectedRanges] count]; indexRange++){
        // get the range
        [[[_currentTextView selectedRanges] objectAtIndex:indexRange] getValue:&range];
        
        // invalidate and ranges that are outside the bounds of the string
        if (([[[_currentTextView textStorage] string] length] == 0) || (range.location > [[[_currentTextView textStorage] string] length]) || ((range.location + range.length)>[[[_currentTextView textStorage] string] length])){
            // in this case set the value to the default font for the text storage
            font = [_currentTextView font];
#warning textview font attribute
            if (attribute == EDFontAttributeName)
                [results setObject:[font familyName] forKey:EDKeyValue];
            else if (attribute == EDFontAttributeSize)
                [results setObject:[NSNumber numberWithFloat:[font pointSize]] forKey:EDKeyValue];
            
            continue;
        }
        else if (range.location == [[[_currentTextView textStorage] string] length]){
            // retrieve the font
#warning textview font attribute
            font = [[_currentTextView textStorage] attribute:NSFontAttributeName atIndex:(range.location-1) effectiveRange:nil];
            //[results setObject:[font familyName] forKey:EDKeyValue];
            if (attribute == EDFontAttributeName)
                [results setObject:[font familyName] forKey:EDKeyValue];
            else if (attribute == EDFontAttributeSize)
                [results setObject:[NSNumber numberWithFloat:[font pointSize]] forKey:EDKeyValue];
        }
        else{
            // retrieve the font
#warning textview font attribute
            if (range.location > 0){
                font = [[_currentTextView textStorage] attribute:NSFontAttributeName atIndex:(range.location-1) effectiveRange:nil];
            }
            else{
                font = [_currentTextView font];
            }
            //[results setObject:[font familyName] forKey:EDKeyValue];
            if (attribute == EDFontAttributeName)
                [results setObject:[font familyName] forKey:EDKeyValue];
            else if (attribute == EDFontAttributeSize)
                [results setObject:[NSNumber numberWithFloat:[font pointSize]] forKey:EDKeyValue];
        }
        
        // enumerate over all the different attributes that are contained in the string
        [[_currentTextView textStorage] enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(range.location,range.length) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange blockRange, BOOL *stop) {
            
            // get the intersection between the current range and the current block range
            // we are only interested in the intersection of what is selected and the current section of the attributed string
            NSRange intersectionRange = NSIntersectionRange(blockRange, range);
            
            // calling font properties, need to ensure that we're not calling it for a location outside of the string
            if (intersectionRange.length > 0 ){
#warning textview font attribute
                if (attribute == EDFontAttributeName){
                    // get font family name
                    attrValue = [(NSFont *)value familyName];
                    
                    // if value is not the same as the last value then there's a difference
                    if ((savedAttrValue != nil) && (attrValue != nil) && (![savedAttrValue isEqualToString:attrValue])){
                        // there's a difference
                        [results setObject:[NSNumber numberWithBool:TRUE] forKey:EDKeyDiff];
                        *stop = TRUE;
                        return;
                    }
                    
                    [results setObject:attrValue forKey:EDKeyValue];
                    savedAttrValue = attrValue;
                }
                else if (attribute == EDFontAttributeSize){
                    // get font size
                    flAttrValue = [font pointSize];
                    
                    // if value is not the same as the last value then there's a difference
                    if ((flSavedAttrValue != -1) && (flAttrValue != -1) && (flSavedAttrValue != flAttrValue)){
                        // there's a difference
                        [results setObject:[NSNumber numberWithBool:TRUE] forKey:EDKeyDiff];
                        *stop = TRUE;
                        return;
                    }
                
                    [results setObject:[NSNumber numberWithFloat:flAttrValue] forKey:EDKeyValue];
                    flSavedAttrValue = flAttrValue;
                }
            }
        }];
    }
    return results;
}

- (NSDictionary *)getAttributeValueForSelectedRanges:(NSString *)attribute{
    if (_currentTextView == nil){
        // do nothing
        return nil;
    }
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    // set default of FALSE for diff
    [results setObject:[NSNumber numberWithBool:FALSE] forKey:EDKeyDiff];
    
    NSRange effectiveRange, range;
    id savedAttrValue = nil, attrValue = nil;
    // for each range get the attribute
    for (int indexRange = 0; indexRange < [[_currentTextView selectedRanges] count]; indexRange++){
        // get the range
        [[[_currentTextView selectedRanges] objectAtIndex:indexRange] getValue:&range];
        
        // invalidate and ranges that are outside the bounds of the string
        if ((range.location == [[[_currentTextView textStorage] string] length]) || (range.location > [[[_currentTextView textStorage] string] length])){
            continue;
        }
        
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
            
            // invalidate and ranges that are outside the bounds of the string
            if ((range.location == [[[_currentTextView textStorage] string] length]) || (range.location > [[[_currentTextView textStorage] string] length])){
                continue;
            }
        
            [string addAttribute:NSSuperscriptAttributeName value:[NSNumber numberWithInt:1] range:range];
        }
        [string endEditing];
        
        // save
        [_currentTextbox setTextValue:string];
    }
}

#pragma mark button fonts
- (IBAction)onButtonFontsSelected:(id)sender{
    NSRange range;
    
    // do not edit fonts if user selected mixed
    if ([[[buttonFonts selectedItem] title] isEqualToString:EDFontAttributeNameMixed]){
        return;
    }
    
    // start editing
    [[_currentTextView textStorage] beginEditing];
    
    // for each range get the attribute and set the name
    for (int indexRange = 0; indexRange < [[_currentTextView selectedRanges] count]; indexRange++){
        // get range
        [[[_currentTextView selectedRanges] objectAtIndex:indexRange] getValue:&range];
        
        // invalidate and ranges that are outside the bounds of the string
        if ((range.location == [[[_currentTextView textStorage] string] length]) || (range.location > [[[_currentTextView textStorage] string] length])){
            continue;
        }
        
        // format the text accordingly
        [[_currentTextView textStorage] enumerateAttribute:NSFontAttributeName inRange:NSMakeRange(0,[[_currentTextView textStorage] length]) options:NSAttributedStringEnumerationLongestEffectiveRangeNotRequired usingBlock:^(id value, NSRange blockRange, BOOL *stop) {
            
            // get the intersection between the current range and the current block range
            NSRange intersectionRange = NSIntersectionRange(blockRange, range);
            NSFont *oldFont, *newFont;
            if (intersectionRange.length > 0 ){
                oldFont = [[_currentTextView textStorage] attribute:NSFontAttributeName atIndex:intersectionRange.location effectiveRange:nil];
                newFont = [NSFont fontWithName:[[buttonFonts selectedItem] title] size:[oldFont pointSize]];
                // go through the sting and update the characters based on the range
                // remove default
                [[_currentTextView textStorage] removeAttribute:NSFontAttributeName range:intersectionRange];
                
                // add custom attributes
                [[_currentTextView textStorage] addAttribute:NSFontAttributeName value:newFont range:intersectionRange];
            }
        }];
    }
    
    // end editing
    [[_currentTextView textStorage] endEditing];
    
    // save
    [_currentTextbox setTextValue:[_currentTextView textStorage]];
}

- (void)setUpFontButton{
    NSString *fontName;
    
    // populate font button
    NSMutableArray *fontList = [[NSMutableArray alloc] initWithArray:[[NSFontManager sharedFontManager] availableFontFamilies]];
    [fontList sortUsingSelector:@selector(caseInsensitiveCompare:)];
    [buttonFonts removeAllItems];
    [buttonFonts addItemsWithTitles:fontList];
    
    NSDictionary *font = [self getFontAttributeValueForSelectedRanges:EDFontAttributeName];
    
    // if there is no difference in values and the font is set then set selected item
    if ((![[font objectForKey:EDKeyDiff] boolValue]) && ([font objectForKey:EDKeyValue] != nil)){
        fontName = (NSString *)[font objectForKey:EDKeyValue];
        
        // set selection
        [buttonFonts selectItemWithTitle:fontName];
    }
    else if (([[font objectForKey:EDKeyDiff] boolValue]) && ([font objectForKey:EDKeyValue] != nil)){
        // insert blank name at the beginning of the font list
        [buttonFonts insertItemWithTitle:[NSString stringWithFormat:@"%@",EDFontAttributeNameMixed] atIndex:0];
        [buttonFonts selectItemAtIndex:0];
    }
}

#pragma mark font size
- (void)onFontSizeDidChange:(NSNotification *)note{
    NSRange effectiveRange, range;
    NSFont *oldFont = nil, *newFont = nil;
    NSLog(@"font size was changed to:%f", [[fieldFontSize stringValue] floatValue]);
    // start editing
    [[_currentTextView textStorage] beginEditing];
    
    // for each range get the attribute and set the name
    for (int indexRange = 0; indexRange < [[_currentTextView selectedRanges] count]; indexRange++){
        // get range
        [[[_currentTextView selectedRanges] objectAtIndex:indexRange] getValue:&range];
        
        // invalidate and ranges that are outside the bounds of the string
        if ((range.location == [[[_currentTextView textStorage] string] length]) || (range.location > [[[_currentTextView textStorage] string] length])){
            continue;
        }
        
        oldFont = [[_currentTextView textStorage] attribute:NSFontAttributeName atIndex:range.location effectiveRange:&effectiveRange];
        
        // we now have the NSFont name, reset the font name
        newFont = [NSFont fontWithName:[oldFont fontName] size:[[fieldFontSize stringValue] floatValue]];
        
        // remove old
        [[_currentTextView textStorage] removeAttribute:NSFontAttributeName range:range];
        
        // add new
        [[_currentTextView textStorage] addAttribute:NSFontAttributeName value:newFont range:range];
    }
    
    // end editing
    [[_currentTextView textStorage] endEditing];
    
    // save
    [_currentTextbox setTextValue:[_currentTextView textStorage]];
}

- (void)setUpFontSizeField{
    float fontSize;
    NSDictionary *fontInfo = [self getFontAttributeValueForSelectedRanges:EDFontAttributeSize];
    
    // if there is no difference in values and the font is set then set selected item
    if ((![[fontInfo objectForKey:EDKeyDiff] boolValue]) && ([fontInfo objectForKey:EDKeyValue] != nil)){
        fontSize = [[fontInfo objectForKey:EDKeyValue] floatValue];
        
        NSLog(@"setting up font size:%f", fontSize);
        [fieldFontSize setStringValue:[NSString stringWithFormat:@"%f", fontSize]];
    }
    else if (([[fontInfo objectForKey:EDKeyDiff] boolValue]) && ([fontInfo objectForKey:EDKeyValue] != nil)){
        // insert nothing in field
        [fieldFontSize setStringValue:[NSString stringWithFormat:@""]];
    }
}

@end
