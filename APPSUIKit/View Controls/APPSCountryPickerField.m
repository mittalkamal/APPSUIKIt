//
//  APPSCountryPickerField.m
//  Appstronomy UIKit
//
//  Created by Chris Morris on 7/16/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

@import APPSFoundation;

#import "APPSCountryPickerField.h"

@implementation APPSCountryPickerField



#pragma mark - Lifecycle

/**
 Created via alloc/init.
 */
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        [self setup];
    }

    return self;
}

/**
 Created via a NIB or Storyboard.
 */
- (void)awakeFromNib
{
    [super awakeFromNib];

    [self setup];
}

/**
 Default the list to the adjusted country list.
 */
- (void)setup
{
    self.optionList = [[self class] allCountryNamesAdjusted];
    self.valueList  = [[self class] allCountryCodesAdjusted];
}



#pragma mark - Properties

- (void)setCountryName:(NSString *)countryName
{
    self.selectedOption = countryName;
}

- (NSString *)countryName
{
    return self.selectedOption;
}

- (void)setCountryCode:(NSString *)countryCode
{
    self.selectedValue = countryCode;
}

- (NSString *)countryCode
{
    return self.selectedValue;
}



#pragma mark - Class Methods


#pragma mark Helpers

/**
 This array is composed of country, country code pairs.  Each element in the
 array is a two element array.  The first element in this two element array
 is the country code, and the second element is the display name for that
 country code.  The larger array is sorted by the country display name (the
 second element).
 */
+ (NSArray *)allCountryCodesAndNames
{
    static NSArray         *allCountryCodesAndNames;
    static dispatch_once_t  onceToken;

    dispatch_once(&onceToken, ^{
        NSLocale       *currentLocale               = [NSLocale currentLocale];
        NSMutableArray *mutableCountryCodesAndNames = [[NSMutableArray alloc] init];
        NSString       *countryName;

        logInfo(@"My country codes list is %@", [NSLocale ISOCountryCodes]);
        for (NSString *countryCode in [NSLocale ISOCountryCodes]) {
            countryName = [currentLocale displayNameForKey:NSLocaleCountryCode
                                                     value:countryCode];
            logInfo(@"Country name is %@ for country code of %@", countryName, countryCode);
            // Just in case one of them comes back nil (which none do currently)
            if (countryName && countryCode) {
                [mutableCountryCodesAndNames addObject:@[countryCode, countryName]];
            }
        }

        allCountryCodesAndNames = [mutableCountryCodesAndNames sortedArrayUsingComparator:^NSComparisonResult(NSArray *obj1, NSArray *obj2) {
            return [obj1[1] caseInsensitiveCompare:obj2[1]];
        }];
    });

    return allCountryCodesAndNames;
}


/**
 This is a little overkill, but instead of doing this in each of the adjusted
 methods, we confirm that there is no chance of something getting out of sync
 by getting the name and the code at the same time.
 */
+ (NSArray *)allCountryCodesAndNamesAdjusted
{
    static NSArray         *allCountryCodesAndNamesAdjusted;
    static dispatch_once_t  onceToken;

    dispatch_once(&onceToken, ^{
        NSLocale *currentLocale   = [NSLocale currentLocale];
        NSString *countryCode     = [currentLocale objectForKey:NSLocaleCountryCode];
        NSString *countryName     = [currentLocale displayNameForKey:NSLocaleCountryCode
                                                               value:countryCode];
        
        NSArray  *valuesToPrepend =@[@[@"", @""]];
        if (countryCode && countryName) {
            valuesToPrepend =  [valuesToPrepend arrayByAddingObjectsFromArray:@[@[countryCode, countryName]]];
        }
        if (![@"United States" isEqualToString:countryName] || ![@"US" isEqualToString:countryCode]) {
            valuesToPrepend =  [valuesToPrepend arrayByAddingObjectsFromArray:@[@[@"US",@"United States"]]];
        }
        allCountryCodesAndNamesAdjusted = [valuesToPrepend arrayByAddingObjectsFromArray:[self allCountryCodesAndNames]];
    });

    return allCountryCodesAndNamesAdjusted;
}


#pragma mark Publicly Exposed

/**
 The list of the country names available in the system locale.
 */
+ (NSArray *)allCountryNames
{
    static NSArray         *allCountryNames;
    static dispatch_once_t  onceToken;

    dispatch_once(&onceToken, ^{
        NSMutableArray *mutableCountryNames = [[NSMutableArray alloc] init];


        for (NSArray *countryCodeAndName in [self allCountryCodesAndNames]) {
            [mutableCountryNames addObject:countryCodeAndName[1]];
        }

        allCountryNames = [mutableCountryNames copy];
    });

    return allCountryNames;
}

/**
 The list of the country codes in the system sorted in the same order as the
 allCountryNames list.
 */
+ (NSArray *)allCountryCodes
{
    static NSArray         *allCountryCodes;
    static dispatch_once_t  onceToken;

    dispatch_once(&onceToken, ^{
        NSMutableArray *mutableCountryCodes = [[NSMutableArray alloc] init];


        for (NSArray *countryCodeAndName in [self allCountryCodesAndNames]) {
            [mutableCountryCodes addObject:countryCodeAndName[0]];
        }

        allCountryCodes = [mutableCountryCodes copy];
    });

    return allCountryCodes;
}

/**
 Add a blank entry and the local country to the top.
 */
+ (NSArray *)allCountryNamesAdjusted
{
    static NSArray         *allCountryNamesAdjusted;
    static dispatch_once_t  onceToken;

    dispatch_once(&onceToken, ^{
        NSMutableArray *mutableCountryNamesAdjusted = [[NSMutableArray alloc] init];


        for (NSArray *countryCodeAndName in [self allCountryCodesAndNamesAdjusted]) {
            [mutableCountryNamesAdjusted addObject:countryCodeAndName[1]];
        }

        allCountryNamesAdjusted = [mutableCountryNamesAdjusted copy];
    });
    
    return allCountryNamesAdjusted;
}

/**
 Add a blank entry and the local country to the top.
 */
+ (NSArray *)allCountryCodesAdjusted
{
    static NSArray         *allCountryCodesAdjusted;
    static dispatch_once_t  onceToken;

    dispatch_once(&onceToken, ^{
        NSMutableArray *mutableCountryCodesAdjusted = [[NSMutableArray alloc] init];


        for (NSArray *countryCodeAndName in [self allCountryCodesAndNamesAdjusted]) {
            [mutableCountryCodesAdjusted addObject:countryCodeAndName[0]];
        }

        allCountryCodesAdjusted = [mutableCountryCodesAdjusted copy];
    });

    return allCountryCodesAdjusted;
}

@end
