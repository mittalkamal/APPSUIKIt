//
//  APPSComposedDataSource.h
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
 A subclass of APPSDataSource with multiple child data sources. Child data sources may have multiple sections. Load content messages will be sent to all child data sources.
 */


#import "APPSDataSource.h"

NS_ASSUME_NONNULL_BEGIN

/**
 A data source that is composed of other data sources.
 */
@interface APPSComposedDataSource : APPSDataSource


/**
 Add a data source to the data source.
 */
- (void)addDataSource:(APPSDataSource *)dataSource;

/**
 Remove the specified data source from this data source.
 */
- (void)removeDataSource:(APPSDataSource *)dataSource;

@end


NS_ASSUME_NONNULL_END
