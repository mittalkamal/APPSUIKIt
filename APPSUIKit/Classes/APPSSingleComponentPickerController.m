//
//  APPSSingleComponentPickerController.m
//
//  Created by Ken Grigsby on 12/4/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

@import APPSFoundation;

#import "APPSSingleComponentPickerController.h"

#define APPSSingleComponentPickerDisplayName(obj) [obj valueForKeyPath:self.displayNameKeyPath ?: @"description"]

// The default row height was clipping the text 'g' in 'mg' so a larger
// height is used.
static const CGFloat kUIPickerRowHeight = 30.0;


@interface APPSSingleComponentPickerController () <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, copy) NSArray *items;
@end

@implementation APPSSingleComponentPickerController



#pragma mark - Property Overrides

- (NSArray *)items
{
    if (!_items && self.fetchObjects) {
        _items = self.fetchObjects();
    }
    
    return _items;
}


- (void)setPickerView:(UIPickerView *)pickerView
{
    _pickerView = pickerView;
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    
    // Select initial display name if provided
    NSString *selectedDisplayName = self.selectedDisplayName;
    NSInteger rowToSelect = [self rowForDisplayName:selectedDisplayName];
    if (rowToSelect != NSNotFound) {
        [_pickerView selectRow:rowToSelect inComponent:0 animated:NO];
    }
    else {
        logInfo(@"%@ Couldn't find '%@' in list of items.", NSStringFromSelector(_cmd), selectedDisplayName);
    }
}


- (void)setSelectedItem:(id)selectedItem
{
    [self setSelectedItem:selectedItem animated:NO];
}


- (void)setSelectedItem:(id)selectedItem animated:(BOOL)animated
{
    [self setSelectedDisplayName:APPSSingleComponentPickerDisplayName(selectedItem) animated:animated];
}


- (NSString *)selectedDisplayName
{
    return self.selectedItem ? APPSSingleComponentPickerDisplayName(self.selectedItem) : nil;
}


- (void)setSelectedDisplayName:(NSString *)displayName
{
    [self setSelectedDisplayName:displayName animated:NO];
}


- (void)setSelectedDisplayName:(NSString *)displayName animated:(BOOL)animated
{
    NSInteger row = [self rowForDisplayName:displayName];
    _selectedItem = (row != NSNotFound) ? [self itemAtRow:row] : nil;
    if (row != NSNotFound) {
        [_pickerView selectRow:row inComponent:0 animated:animated];
    }
}



#pragma mark - Protocol: UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.items.count + (self.showEmptyItem ? 1 : 0);
}



#pragma mark - Protocol: UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    id obj = [self itemAtRow:row];
    return APPSSingleComponentPickerDisplayName(obj) ?: @"";
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedItem = [self itemAtRow:row];
    
    if (self.didSelect) {
        self.didSelect(self);
    }
}


- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component;
{
    return kUIPickerRowHeight;
}



#pragma mark - Private

- (id)itemAtRow:(NSInteger)row
{
    if (self.showEmptyItem && row == 0) {
        return nil;
    }
    
    if (self.showEmptyItem) {
        --row;
    }
    
    return self.items[row];
}


- (NSInteger)rowForDisplayName:(NSString *)displayName
{
    NSInteger rowToSelect = NSNotFound;
    if ((displayName.length == 0) && self.showEmptyItem) {
        rowToSelect = 0;
    }
    else if (displayName.length) {
        
        NSUInteger index = [self.items indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            if ([displayName isEqualToString:APPSSingleComponentPickerDisplayName(obj)]) {
                *stop = YES;
                return YES;
            }
            return NO;
        }];
        
        if (index != NSNotFound) {
            rowToSelect = index;
            
            if (self.showEmptyItem) {
                ++rowToSelect;
            }
        }
    }
    
    return rowToSelect;
}

@end
