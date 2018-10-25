//
//  APPSDataSource_Private.h
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
 The base data source class.
 
 This file contains methods used internally by subclasses. These methods are not considered part of the public API of APPSDataSource. It is possible to implement fully functional data sources without using these methods.
 */

#import "APPSDataSource.h"

NS_ASSUME_NONNULL_BEGIN

@protocol APPSDataSourceDelegate;
@class APPSTablePlaceholderView;

// View tag for placeholder view
enum {
    APPSDataSourcePlaceholderTag = -10000
};


@interface APPSDataSourcePlaceholder ()
/// Is this placeholder an activity indicator?
@property (nonatomic) BOOL activityIndicator;

/// Create a placeholder that shows an activity indicator
+ (instancetype)placeholderWithActivityIndicator;

@end



@interface APPSDataSource ()

/// Create an instance of the placeholder view for this data source.
- (APPSTablePlaceholderView *)dequeuePlaceholderViewForTableView:(UITableView *)tableView;

/// Should an activity indicator be displayed while we're refreshing the content. Default is NO.
@property (nonatomic, readonly) BOOL showsActivityIndicatorWhileRefreshingContent;

/// Will this data source show an activity indicator given its current state?
@property (nonatomic, readonly) BOOL shouldShowActivityIndicator;

/// Will this data source show a placeholder given its current state?
@property (nonatomic, readonly) BOOL shouldShowPlaceholder;

/// Load the content of this data source.
- (void)loadContent;
/// The internal method which is actually called by loadContent. This allows subclasses to perform pre- and post-loading activities.
- (void)beginLoadingContentWithProgress:(APPSLoadingProgress *)progress;
/// The internal method called when loading is complete. Subclasses may implement this method to provide synchronisation of child data sources.
- (void)endLoadingContentWithState:(NSString *)state error:(nullable NSError *)error update:(dispatch_block_t)update;

/// Display an activity indicator for this data source. If sections is nil, display the activity indicator for the entire data source. The sections must be contiguous.
- (void)presentActivityIndicatorForSections:(nullable NSIndexSet *)sections;

/// Display a placeholder for this data source. If sections is nil, display the placeholder for the entire data source. The sections must be contiguous.
- (void)presentPlaceholder:(nullable APPSDataSourcePlaceholder *)placeholder forSections:(nullable NSIndexSet *)sections;

/// Dismiss a placeholder or activity indicator
- (void)dismissPlaceholderForSections:(nullable NSIndexSet *)sections;

/// Update the placeholder view for a given section.
- (void)updatePlaceholderView:(APPSTablePlaceholderView *)placeholderView forSectionAtIndex:(NSInteger)sectionIndex;

/// State machine delegate method for notifying that the state is about to change. This is used to update the loadingState property.
- (void)stateWillChange;
/// State machine delegate method for notifying that the state has changed. This is used to update the loadingState property.
- (void)stateDidChange;

/// Get an index path for the data source represented by the global index path. This works with -dataSourceForSectionAtIndex:.
- (NSIndexPath *)localIndexPathForGlobalIndexPath:(NSIndexPath *)globalIndexPath;

/// Is this data source the root data source? This depends on proper set up of the delegate property. Container data sources ALWAYS act as the delegate for their contained data sources.
@property (nonatomic, readonly, getter = isRootDataSource) BOOL rootDataSource;

/// A delegate object that will receive change notifications from this data source.
@property (nullable, nonatomic, weak) id<APPSDataSourceDelegate> delegate;

/// Notify the parent data source that this data source will load its content. Unlike other notifications, this notification will not be propagated past the parent data source.
- (void)notifyWillLoadContent;

/// Notify the parent data source that this data source has finished loading its content with the given error (nil if no error). Unlike other notifications, this notification will not propagate past the parent data source.
- (void)notifyContentLoadedWithError:(NSError *)error;

- (void)notifySectionsInserted:(NSIndexSet *)sections;
- (void)notifySectionsRemoved:(NSIndexSet *)sections;
- (void)notifySectionMovedFrom:(NSInteger)section to:(NSInteger)newSection;
- (void)notifySectionsRefreshed:(NSIndexSet *)sections;

@end



@protocol APPSDataSourceDelegate <NSObject>
@optional

- (void)dataSource:(APPSDataSource *)dataSource didInsertItemsAtIndexPaths:(NSArray *)indexPaths;
- (void)dataSource:(APPSDataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)indexPaths;
- (void)dataSource:(APPSDataSource *)dataSource didRefreshItemsAtIndexPaths:(NSArray *)indexPaths;
- (void)dataSource:(APPSDataSource *)dataSource didMoveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)newIndexPath;

- (void)dataSource:(APPSDataSource *)dataSource didInsertSections:(NSIndexSet *)sections;
- (void)dataSource:(APPSDataSource *)dataSource didRemoveSections:(NSIndexSet *)sections;
- (void)dataSource:(APPSDataSource *)dataSource didRefreshSections:(NSIndexSet *)sections;
- (void)dataSource:(APPSDataSource *)dataSource didMoveSection:(NSInteger)section toSection:(NSInteger)newSection;

- (void)dataSourceDidReloadData:(APPSDataSource *)dataSource;
- (void)dataSource:(APPSDataSource *)dataSource performBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete;

/// If the content was loaded successfully, the error will be nil.
- (void)dataSource:(APPSDataSource *)dataSource didLoadContentWithError:(NSError *)error;

/// Called just before a datasource begins loading its content.
- (void)dataSourceWillLoadContent:(APPSDataSource *)dataSource;

/// Present an activity indicator. The sections must be contiguous.
- (void)dataSource:(APPSDataSource *)dataSource didPresentActivityIndicatorForSections:(NSIndexSet *)sections;

/// Present a placeholder for a set of sections. The sections must be contiguous.
- (void)dataSource:(APPSDataSource *)dataSource didPresentPlaceholderForSections:(NSIndexSet *)sections;

/// Remove a placeholder for a set of sections.
- (void)dataSource:(APPSDataSource *)dataSource didDismissPlaceholderForSections:(NSIndexSet *)sections;

@end



NS_ASSUME_NONNULL_END
