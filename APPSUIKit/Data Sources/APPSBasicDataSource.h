//
//  APPSBasicDataSource.h
//
//  Created by Ken Grigsby on 8/24/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//
// This code was taken from the WWDC 2015 Sample Code for Session AdvancedCollectionView: Advanced User Interfaces Using Collection View
// https://developer.apple.com/sample-code/wwdc/2015/?q=advanced%20user%20interfaces.

/**
 
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A subclass of APPSDataSource which permits only one section but manages its items in an NSArray. This class will perform all the necessary updates to animate changes to the array of items if they are updated using -setItems:animated:.
 */


#import "APPSDataSource.h"

NS_ASSUME_NONNULL_BEGIN


/**
 A subclass of APPSDataSource which permits only one section but manages its items in an NSArray. This class will perform all the necessary updates to animate changes to the array of items if they are updated using -setItems:animated:.
 */
@interface APPSBasicDataSource : APPSDataSource

/// The items represented by this data source. This property is KVC compliant for mutable changes via -mutableArrayValueForKey:.
@property (nonatomic, copy) NSArray *items;

/// Set the items with optional animation. By default, setting the items is not animated.
- (void)setItems:(NSArray *)items animated:(BOOL)animated;

@end




NS_ASSUME_NONNULL_END
