//
//  APPSDataSource.h
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
 */

@import UIKit;
#import "APPSContentLoading.h"

NS_ASSUME_NONNULL_BEGIN


/**
 A general purpose placeholder class for representing the no content or error message placeholders in a data source.
 */
@interface APPSDataSourcePlaceholder : NSObject <NSCopying>

/// The title of the placeholder. This is typically displayed larger than the message.
@property (nullable, nonatomic, copy) NSString *title;
/// The message of the placeholder. This is typically displayed in using a smaller body font.
@property (nullable, nonatomic, copy) NSString *message;
/// An image for the placeholder. This is displayed above the title.
@property (nullable, nonatomic, strong) UIImage *image;

/// Method for creating a placeholder. One of title or message must not be nil.
+ (instancetype)placeholderWithTitle:(nullable NSString *)title message:(nullable NSString *)message image:(nullable UIImage *)image;

@end


/**
 The AAPLDataSource class is a concrete implementation of the `UITableViewDataSource` protocol designed to support composition and sophisticated layout delegated to individual sections of the data source.
 
 At a minimum, subclasses should implement the following methods for managing items:
 
 - -numberOfSections
 - -itemAtIndexPath:
 - -indexPathsForItem:
 - -removeItemAtIndexPath:
 - -numberOfItemsInSection:
 
 Subclasses should implement `-registerReusableViewsWithTableView:` to register their views for cells. Note, calling super is mandatory to ensure all views for headers and footers are properly registered. For example:
 
 -(void)registerReusableViewsWithTableView:(UITableView *)tableView
 {
    [super registerReusableViewsWithTableView:tableView];
    [tableView registerCell:[MyCell class] forCellWithReuseIdentifier:AAPLReusableIdentifierFromClass(MyCell)];
 }
 
 Subclasses will need to implement the `UITableView` data source method `-tableView:cellForItemAtIndexPath:` to return a configured cell. For example:
 
 -(UITableViewCell *)tableView:(UITableView *)tableView cellForItemAtIndexPath:(NSIndexPath *)indexPath
 {
    MyCell *cell = [tableView dequeueReusableCellWithReuseIdentifier:AAPLReusableIdentifierFromClass(MyCell) forIndexPath:indexPath];
    MyItem *item = [self itemAtIndexPath:indexPath];
    // ... configure the cell with the item
    return cell;
 }
 
 For subclasses that need to load their content, implementing `-loadContentWithProgress:` is the answer. This method will always be called as the data source transitions from the initial state (`AAPLLoadStateInitial`) to the content loaded state (`AAPLLoadStateContentLoaded`). The default implementation simply calls the complete method on the progress object to transition into the content loaded state. Subclasses can implement more complex loading logic. For example:
 
 -(void)loadContentWithProgress:(AAPLLoadingProgress *)progress
 {
    [ServerManager fetchMyItemsWithCompletionHandler:^(NSArray<MyItem *> *items, NSError *error) {
        if (progress.cancelled)
            return;
 
        if (error) {
            [progress completeWithError:error];
            return;
        }
 
        // It's important to only reference the data source via the parameter to prevent creation of retain cycles
        [progress updateWithContent:^(MyDataSource *me) {
            // store the items
        }];
    }];
 }
 
 */
@interface APPSDataSource : NSObject <UITableViewDataSource, APPSContentLoading>

- (instancetype)init NS_DESIGNATED_INITIALIZER;

/// The title of this data source. This value is used to populate section headers and the segmented control tab.
@property (nullable, nonatomic, copy) NSString *title;

/// The number of sections in this data source.
@property (nonatomic, readonly) NSInteger numberOfSections;

/// Return the number of items in a specific section. Implement this instead of the UITableViewDataSource method.
- (NSInteger)numberOfRowsInSection:(NSInteger)sectionIndex;

/// Find the data source for the given section. Default implementation returns self.
- (APPSDataSource *)dataSourceForSectionAtIndex:(NSInteger)sectionIndex;

/// Find the item at the specified index path. Returns nil when indexPath does not specify a valid item in the data source.
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

/// Find the index paths of the specified item in the data source. An item may appear more than once in a given data source.
- (NSArray*)indexPathsForItem:(id)item;

/// Remove an item from the data source. This method should only be called as the result of a user action, such as tapping the "Delete" button in a swipe-to-delete gesture. Automatic removal of items due to outside changes should instead be handled by the data source itself — not the controller. Data sources must implement this to support swipe-to-delete.
- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath;

/// Called when a data source becomes active in a table view. If the data source is in the `AAPLLoadStateInitial` state, it will be sent a `-loadContent` message.
- (void)didBecomeActive NS_REQUIRES_SUPER;

/// Called when a data source becomes inactive in a table view
- (void)willResignActive NS_REQUIRES_SUPER;

/// Should this data source allow its items to be selected? The default value is YES.
@property (nonatomic) BOOL allowsSelection;

#pragma mark - Notifications

/// Update the state of the data source in a safe manner. This ensures the table view will be updated appropriately.
- (void)performUpdate:(dispatch_block_t)update complete:(nullable dispatch_block_t)complete;

/// Update the state of the data source in a safe manner. This ensures the table view will be updated appropriately.
- (void)performUpdate:(dispatch_block_t)update;

/// Notify the parent data source and the table view that new items have been inserted at positions represented by insertedIndexPaths.
- (void)notifyItemsInsertedAtIndexPaths:(NSArray *)insertedIndexPaths;
/// Notify the parent data source and table view that the items represented by removedIndexPaths have been removed from this data source.
- (void)notifyItemsRemovedAtIndexPaths:(NSArray *)removedIndexPaths;
/// Notify the parent data sources and table view that the items represented by refreshedIndexPaths have been updated and need redrawing.
- (void)notifyItemsRefreshedAtIndexPaths:(NSArray *)refreshedIndexPaths;
/// Alert parent data sources and the table view that the item at indexPath was moved to newIndexPath.
- (void)notifyItemMovedFromIndexPath:(NSIndexPath *)indexPath toIndexPaths:(NSIndexPath *)newIndexPath;

/// Notify parent data sources and the table view that the sections were inserted.
- (void)notifySectionsInserted:(NSIndexSet *)sections;
/// Notify parent data sources and (eventually) the table view that the sections were removed.
- (void)notifySectionsRemoved:(NSIndexSet *)sections;
/// Notify parent data sources and the table view that the section at oldSectionIndex was moved to newSectionIndex.
- (void)notifySectionMovedFrom:(NSInteger)oldSectionIndex to:(NSInteger)newSectionIndex;
/// Notify parent data sources and ultimately the table view the specified sections were refreshed.
- (void)notifySectionsRefreshed:(NSIndexSet *)sections;

/// Notify parent data sources and ultimately the table view that the data in this data source has been reloaded.
- (void)notifyDidReloadData;



#pragma mark - Placeholders

/// The placeholder to show when the data source is in the No Content state.
@property (nullable, nonatomic, copy) APPSDataSourcePlaceholder *noContentPlaceholder;

/// The placeholder to show when the data source is in the Error state.
@property (nullable, nonatomic, copy) APPSDataSourcePlaceholder *errorPlaceholder;

#pragma mark - Subclass hooks

/// Register reusable views needed by this data source
- (void)registerReusableViewsWithTableView:(UITableView *)tableView NS_REQUIRES_SUPER;

#pragma mark - Content loading

/// Signal that the datasource SHOULD reload its content
- (void)setNeedsLoadContent;

/// Reset the content and loading state.
- (void)resetContent NS_REQUIRES_SUPER;

/// Use this method to wait for content to load. The block will be called once the loadingState has transitioned to the ContentLoaded, NoContent, or Error states. If the data source is already in that state, the block will be called immediately.
- (void)whenLoaded:(dispatch_block_t)block;

@end

#if DEBUG
extern BOOL APPSInDataSourceUpdate(APPSDataSource *dataSource);
/// Assertion for ensuring that the executing code is operating within an update block.
#define APPS_ASSERT_IN_DATASOURCE_UPDATE() NSAssert(APPSInDataSourceUpdate(self), @"%@ expected to be called within update block", NSStringFromSelector(_cmd));
#else
#define APPS_ASSERT_IN_DATASOURCE_UPDATE()
#endif




NS_ASSUME_NONNULL_END
