//
//  EDPanelViewController.h
//  GraphPouch
//
//  Created by PATRICK LEE on 9/10/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface EDPanelViewController : NSViewController{
    NSNotificationCenter *_nc;
    NSManagedObjectContext *_context;
}
- (void)initWindowAfterLoaded:(NSManagedObjectContext *)context;
- (void)setElementLabel:(NSTextField *)label attribute:(NSString *)attribute;
- (void)setElementCheckbox:(NSButton *)checkbox attribute:(NSString *)attribute;
- (void)setLabelState:(NSTextField *)label hasChange:(BOOL)diff value:(float)labelValue;
- (NSMutableDictionary *)checkForSameFloatValueInLabelsForKey:(NSString *)key;
- (NSMutableDictionary *)checkForSameBoolValueInLabelsForKey:(NSString *)key;
- (NSMutableDictionary *)checkForSameIntValueInLabelsForKey:(NSString *)key;
- (void)changeSelectedElementsAttribute:(NSString *)key newValue:(id)newValue;
@end
