//
//  APPSPickerField.m
//  Appstronomy UIKit
//
//  Created by Chris Morris on 7/15/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import "APPSPickerField.h"

@interface APPSPickerField () <UIPickerViewDelegate, UIPickerViewDataSource>

/**
 The UIPickerView that will be used as the inputView for the field.
 */
@property (strong, nonatomic) UIPickerView *pickerView;

/**
 The index of the selected item.
 */
@property (nonatomic) NSUInteger selectedIndex;

@end

@implementation APPSPickerField

#pragma mark - Overridden from UITextField

/**
 Don't allow this to be overridden by an outsider, as this is the main
 point of this class.
 */
- (UIView *)inputView
{
    return self.pickerView;
}

/**
 This is a simple approach for hiding the caret for the text field.  This
 causes a problem if you want to allow for select/select all ... but I am 
 not concerned with that case currently.
 
 Another option is to move the location of the cursor by overriding 
 caretRectForPosition:, but that solution felt a little uglier:
 
 http://stackoverflow.com/questions/3699727/hide-the-cursor-of-an-uitextfield/13660503#13660503
 */
- (UIColor *)tintColor
{
    return [UIColor clearColor];
}

/**
 Prevents the text from being set to a value that does not exist in the list
 of possible options.  If a bad value is provided, this behaves as a no-op,
 leaving the previous value intact.  (It does not set the value to nil.)
 
 Additionally, the pickerView is advanced to the option in the list
 that corresponds with this text value.
 
 NOTE: I chose not to reconfirm the text in the case that a new optionList is
       set AFTER the text has been set.  I felt like this wasn't needed now,
       and I don't know that such behavior would be desirable.  If we want it,
       we would simply need to update the optionList setter to update the
       text.  A simple solution would be to get the existing text, clear the
       existing text, then set it again to the old text.
 
 TODO: It appears that cut/paste do not go through this method.  Currently,
       I have disabled those options from the UIMenuController, but if
       they were enabled, it would be nice to know that a clever user couldn't
       make our text invalid.  I haven't ventured down this path too much, as it
       is not a needed feature at this time.
 */
- (void)setText:(NSString *)text
{
    // Just in case nil comes in, we will look for an empty string.
    if (!text) {
        text = @"";
    }

    NSUInteger newIndex = [self.optionList indexOfObject:text];

    // If we don't find the option, then let's just stop and leave the
    // current selected value.
    if (newIndex == NSNotFound) {
        return;
    }

    self.selectedIndex = newIndex;

    [self.pickerView selectRow:self.selectedIndex
                   inComponent:0
                      animated:YES];

    // We are doing this last, so that it is not set if the new value is invalid
    [super setText:text];
}

/**
 Prevents the UIMenuController from offering any options other than
 "Select All" or "Copy" as we don't want to allow the user to cut/paste into
 the field, and "Select" won't work because we have made the caret invisible.
 */
- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(selectAll:) || action == @selector(copy:)) {
        return [super canPerformAction:action withSender:sender];
    }

    return NO;
}

/**
 It appears that if user interaction is disabled on a TextField, then it cannot
 become the first responder.  This seems like a legitimate case if I want to
 prevent any of the UIMenuController options from being displayed.
 */
- (BOOL)canBecomeFirstResponder
{
    return self.isEnabled || [super canBecomeFirstResponder];
}

#pragma mark - Properties

/**
 Lazily instantiates the UIPickerView and sets the delegate and dataSource.
 */
- (UIPickerView *)pickerView
{
    if (!_pickerView) {
        _pickerView            = [[UIPickerView alloc] init];
        _pickerView.delegate   = self;
        _pickerView.dataSource = self;
    }

    return _pickerView;
}

/**
 Reset the valueList and the selectedIndex.
 */
- (void)setOptionList:(NSArray *)optionList
{
    if (self.valueList) {
        // Reset the valueList if we are getting a new optionList
        self.valueList     = nil;
        self.selectedIndex = NSNotFound;
    }

    _optionList = optionList;
}

/**
 Confirm that the valueList is "acceptable", if not, raise an exception.
 */
- (void)setValueList:(NSArray *)valueList
{
    if (valueList && !self.optionList) {
        [NSException raise:NSInvalidArgumentException
                    format:@"optionList must be set before setting valueList."];
    }

    if (valueList && ([valueList count] != [self.optionList count])) {
        [NSException raise:NSInvalidArgumentException
                    format:@"The number of elements in the valueList (%lu) must match the optionList (%lu).", (unsigned long)[valueList count], (unsigned long)[self.optionList count]];
    }

    _valueList = valueList;
}

/**
 Putting all of the validation into setText.  This may want to be pulled out
 of there in the future, but it works just fine for now.
 */
- (void)setSelectedOption:(NSString *)selectedOption
{
    self.text = selectedOption;
}

/**
 Confirm we have a selected index first.
 */
- (NSString *)selectedOption
{
    if (!self.optionList || self.selectedIndex == NSNotFound) {
        return nil;
    }

    return self.optionList[self.selectedIndex];
}

/**
 Simply leverages the setSelection method.
 */
- (void)setSelectedValue:(id)selectedValue
{
    if (!self.valueList) {
        return;
    }

    NSUInteger  valueIndex     = [self.valueList indexOfObject:selectedValue];
    NSString   *selectedOption;

    if (valueIndex != NSNotFound) {
        selectedOption = self.optionList[valueIndex];
    }

    self.selectedOption = selectedOption;
}

/**
 Confirm there is a valueList and a selectedIndex.
 */
- (id)selectedValue
{
    if (!self.valueList || self.selectedIndex == NSNotFound) {
        return nil;
    }

    return self.valueList[self.selectedIndex];
}



#pragma mark - UIPickerViewDelegate

/**
 Pull the title from the optionList.
 */
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.optionList[row];
}

/**
 Update the text, and fire the change event.
 */
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedOption = self.optionList[row];

    // Normally, this event is not sent when the text is set, but in this case
    // it makes sense, so that the behavior is just like the keyboard
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
}

#pragma mark - UIPickerViewDataSource

/**
 Only one component supported at this time.
 */
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

/**
 The number of items in the optionList.
 */
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.optionList count];
}

@end
