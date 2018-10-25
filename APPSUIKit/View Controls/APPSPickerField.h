//
//  APPSPickerField.h
//  Appstronomy UIKit
//
//  Created by Chris Morris on 7/15/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 This control is simply a plain old UITextField whose inputView is no
 longer a keyboard, but is a UIPickerView.  For now, it has been designed
 strictly to fit my needs, but it could be expanded easily to offer more robust
 support.  I have attempted to make the implementation rather generic.
 
 This field does not allow a UIMenuController option of anything but "Select All"
 or "Copy".  Even those can be disabled by disabling user interaction for the
 control.  (Normally, if user interaction is disabled, a UITextField cannot 
 become the first responder, but this behavior has been overridden to allow 
 first responder status in this case.)
 
 There is only one component in the UIPickerView at this time.
 
 The option list can must be set before being displayed in order to provide a
 custom list of options.
 
 In order to use this class, an optionList needs to be set to an array of
 strings that will be presented to the user.  The currently selected option can
 be accessed through the text property or the selectedOption property.
 
 Additionally, a valueList can be provided which is an array of objects that must
 be the same length as the optionList array.  This array represents the "value"
 for a given "option".  This can be useful if the display value and the value
 stored are different.  The selectedValue property can be set which will update
 the selectedOption and text values.
 
 TODO: One thing that is unfortunate is that if this field is used on the iPad
       in a view controller that was presented with the FormSheet 
       presentationStyle, then the picker occupies the entire keyboard area,
       which is outside of the bounds of the modal form.  This is something
       that would be nice to address, but I am not going to focus on this now.
 
 The handling of a value of nil on the text, selectedOption, and selectedValue
 could be audited and enhanced.  Currently, nil is just converted to the empty
 string, but this may not be the best option.  It might make sense for the
 text value to be different than the selectedOption in the case when
 an invalid value is set, or nothing has been set ... not sure.  It is beyond
 the necessary use cases currently, but an interesting boundary case to address
 in the future if this gets reused.
 */
@interface APPSPickerField : UITextField

/**
 The list of NSString items presented to the user.  This list must be set before
 presenting the control to the user.  The ordering of this list is the order
 that is presented to the user.  When this is set, any existing valueList
 will be set to nil.
 */
@property (copy, nonatomic) NSArray *optionList;

/**
 The option from the optionList that has been selected by the user.  This
 can be used interchangeably with the text property.  If no valid option has
 been selected, nil is returned.  If the value nil is set, then this "may"
 be a valid value, as nil is converted to "" in the setText method.
 */
@property (copy, nonatomic) NSString *selectedOption;

/**
 Optionally provided in addition to the optionList.  This is a parallel array
 to the optionList array.  This array represents the "value" for a given 
 "option".  This can be useful if the display value and the value
 stored are different.
 
 This must be set AFTER the optionList has been set.  The length of this array
 must match the length of the optionList array, otherwise an InvalidArgument
 exception will be raised.
 */
@property (copy, nonatomic) NSArray *valueList;

/**
 The value associated with the selectedOption.  If there is no valueList 
 provided, this property will return nil.  This property can be used to both
 get and set the selectedValue.  Setting this property will update the selected
 option and text accordingly.  The isEqual: method will be used to find 
 the matching object in the array.  If the selectedValue is not found, then
 the selectedOption is set to nil, which "may" be a valid selected option, since
 it will be converted to the empty string.
 */
@property (copy, nonatomic) id  selectedValue;

@end
