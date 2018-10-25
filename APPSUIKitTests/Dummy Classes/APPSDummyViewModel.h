//
//  APPSDummyViewModel.h
//  AppstronomyStandardKit
//
//  Created by Sohail Ahmed on 1/28/16.
//  Copyright © 2016 Appstronomy, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 This dummy view model class is for use in testing other classes, such as array
 based data sources.
 */
@interface APPSDummyViewModel : NSObject

#pragma mark scalar

@property (assign, nonatomic, getter=isReady) BOOL ready;
@property (assign, nonatomic, getter=isSelected) BOOL selected;
@property (assign, nonatomic) NSUInteger numberOfWidgets;

#pragma mark copy

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *category;

@end
