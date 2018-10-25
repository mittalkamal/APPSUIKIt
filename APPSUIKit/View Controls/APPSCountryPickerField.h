//
//  APPSCountryPickerField.h
//  Appstronomy UIKit
//
//  Created by Chris Morris on 7/16/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import "APPSPickerField.h"

/**
 A simple subclass of the APPSPickerField class which defaults the picker
 list to be the allCountryNamesAdjusted list and the valueList to be 
 addCountryCodesAdjusted.
 
 This could still be set to something different via the optionList property.
 */
@interface APPSCountryPickerField : APPSPickerField

/**
 Simply delegates to the selectedOption of the picker field.
 */
@property (strong, nonatomic) NSString *countryName;

/**
 Simply delegates to the selectedValue of the picker field.
 */
@property (strong, nonatomic) NSString *countryCode;

/**
 A sorted array of all of the country names.
 */
+ (NSArray *)allCountryNames;

/**
 An array of all of the countries in the allCountryNames list.  This array is
 not sorted, but rather it is parallel to the sorted allCountryNames array.
 */
+ (NSArray *)allCountryCodes;

/**
 This is the same list as the allCountryNames list, except that the first entry
 in the list is blank, and the second entry is the country of the users
 current locale (ie. "United States").  This value will also be listed
 later in the alphabetical list.
 */
+ (NSArray *)allCountryNamesAdjusted;

/**
 An array parallel to the allCountryNamesAdjusted array but with the country codes
 in it instead of the country names.
 */
+ (NSArray *)allCountryCodesAdjusted;

@end
