//
//  APPSSegmentedDataSource.h
//
//  Created by Ken Grigsby on 8/24/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//
// This code was taken from the WWDC 2015 Sample Code for Session AdvancedCollectionView: Advanced User Interfaces Using Collection View
// https://developer.apple.com/sample-code/wwdc/2015/?q=advanced%20user%20interfaces.


/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A subclass of AAPLDataSource with multiple child data sources of which only one will be active at a time.
 */

#import "APPSDataSource.h"

NS_ASSUME_NONNULL_BEGIN

/** 
 A subclass of `AAPLDataSource` with multiple child data sources, however, only one data source will be visible at a time.
 
 Only the selected data source will become active. When a new data source is selected, the previously selected data source will receive a `-willResignActive` message before the new data source receives a `-didBecomeActive` message.
 */
@interface APPSSegmentedDataSource : APPSDataSource

/// Add a data source to the end of the collection. The title property of the data source will be used to populate a new segment in the `UISegmentedControl` associated with this data source.
- (void)addDataSource:(APPSDataSource *)dataSource;

/// Remove the data source from the collection.
- (void)removeDataSource:(APPSDataSource *)dataSource;

/// Clear the collection of data sources.
- (void)removeAllDataSources;

/// The default segmented control header for this data source. To hide this header, use shouldDisplayDefaultHeader = NO.
//@property (nonatomic, readonly) APPSLayoutSupplementaryMetrics *segmentedControlHeader;

/// The collection of data sources contained within this segmented data source.
@property (nonatomic, readonly) NSArray *dataSources;

/// Should the data source create a default header that allows switching between the data sources. Set to NO if switching is accomplished through some other means. Default value is YES.
@property (nonatomic) BOOL shouldDisplayDefaultHeader;

/// A reference to the selected data source.
@property (nullable, nonatomic, strong) APPSDataSource *selectedDataSource;

/// The index of the selected data source in the collection.
@property (nonatomic) NSInteger selectedDataSourceIndex;

/// Set the selected data source with animation. By default, setting the selected data source is not animated.
- (void)setSelectedDataSource:(APPSDataSource *)selectedDataSource animated:(BOOL)animated;

/// Set the index of the selected data source with optional animation. By default, setting the selected data source index is not animated.
- (void)setSelectedDataSourceIndex:(NSInteger)selectedDataSourceIndex animated:(BOOL)animated;

/// Call this method to configure a segmented control with the titles of the data sources. This method also sets the target & action of the segmented control to switch the selected data source.
- (void)configureSegmentedControl:(UISegmentedControl *)segmentedControl;

@end


NS_ASSUME_NONNULL_END
