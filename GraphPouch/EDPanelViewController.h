//
//  EDPanelViewController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 9/10/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EDPanelViewController : NSViewController <NSTextFieldDelegate>{
    NSNotificationCenter *_nc;
    NSManagedObjectContext *_context;
    BOOL _fieldChanged;
}

- (void)initWindowAfterLoaded:(NSManagedObjectContext *)context;
- (void)setElementLabel:(NSTextField *)label withStringAttribute:(NSString *)attribute;
- (void)setSlider:(NSSlider *)slider attribute:(NSString *)attribute;
- (void)setElementLabel:(NSTextField *)label attribute:(NSString *)attribute;
- (void)setElementCheckbox:(NSButton *)checkbox attribute:(NSString *)attribute;
- (void)setLabelState:(NSTextField *)label hasChange:(BOOL)diff value:(float)labelValue;
- (void)setLabelState:(NSTextField *)label hasChange:(BOOL)diff stringValue:(NSString *)labelValue;
- (void)viewDidLoad;
- (void)viewWillLoad;
- (NSMutableDictionary *)checkForSameFloatValueInLabelsForKey:(NSString *)key;
- (NSMutableDictionary *)checkForSameBoolValueInLabelsForKey:(NSString *)key;
- (NSMutableDictionary *)checkForSameIntValueInLabelsForKey:(NSString *)key;
- (void)changeSelectedElementsAttribute:(NSString *)key newValue:(id)newValue;
- (void)onControlReceivedFocus:(NSNotification *)note;
@end
