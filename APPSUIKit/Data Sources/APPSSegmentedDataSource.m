//
//  APPSSegmentedDataSource.m
//
//  Created by Ken Grigsby on 8/24/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A subclass of AAPLDataSource with multiple child data sources, however, only one data source will be visible at a time. Load content messages will be sent only to the selected data source. When selected, if a data source is still in the initial state, it will receive a load content message.
 */

#import "APPSDataSource_Private.h"
#import "APPSSegmentedDataSource.h"

NSString * const APPSSegmentedDataSourceHeaderKey = @"APPSSegmentedDataSourceHeaderKey";

@interface APPSSegmentedDataSource () <APPSDataSourceDelegate>
@property (nonatomic, strong) NSMutableArray *mutableDataSources;
@end

@implementation APPSSegmentedDataSource
@synthesize mutableDataSources = _dataSources;



#pragma mark - Instantiation

- (instancetype)init
{
	self = [super init];
	if (!self)
		return nil;
	
	_dataSources = [NSMutableArray array];
	_shouldDisplayDefaultHeader = YES;
	
	return self;
}



#pragma mark - APPSDataSource

- (NSInteger)numberOfSections
{
	return _selectedDataSource.numberOfSections;
}


- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    return [_selectedDataSource numberOfRowsInSection:section];
}


- (APPSDataSource *)dataSourceForSectionAtIndex:(NSInteger)sectionIndex
{
	return [_selectedDataSource dataSourceForSectionAtIndex:sectionIndex];
}


- (NSIndexPath *)localIndexPathForGlobalIndexPath:(NSIndexPath *)globalIndexPath
{
	return [_selectedDataSource localIndexPathForGlobalIndexPath:globalIndexPath];
}



#pragma mark - Property Overrides

- (NSArray *)dataSources
{
	return [NSArray arrayWithArray:_dataSources];
}



#pragma mark - Public Interface

- (void)addDataSource:(APPSDataSource *)dataSource
{
	if (![_dataSources count])
		_selectedDataSource = dataSource;
	[_dataSources addObject:dataSource];
	dataSource.delegate = self;
}


- (void)removeDataSource:(APPSDataSource *)dataSource
{
	[_dataSources removeObject:dataSource];
	if (dataSource.delegate == self)
		dataSource.delegate = nil;
}


- (void)removeAllDataSources
{
	for (APPSDataSource *dataSource in _dataSources) {
		if (dataSource.delegate == self)
			dataSource.delegate = nil;
	}
	
	_dataSources = [NSMutableArray array];
	_selectedDataSource = nil;
}


- (APPSDataSource *)dataSourceAtIndex:(NSInteger)dataSourceIndex
{
	return _dataSources[dataSourceIndex];
}


- (NSInteger)selectedDataSourceIndex
{
	return [_dataSources indexOfObject:_selectedDataSource];
}


- (void)setSelectedDataSourceIndex:(NSInteger)selectedDataSourceIndex
{
	[self setSelectedDataSourceIndex:selectedDataSourceIndex animated:NO];
}


- (void)setSelectedDataSourceIndex:(NSInteger)selectedDataSourceIndex animated:(BOOL)animated
{
	APPSDataSource *dataSource = [_dataSources objectAtIndex:selectedDataSourceIndex];
	[self setSelectedDataSource:dataSource animated:animated completionHandler:nil];
}


- (void)setSelectedDataSource:(APPSDataSource *)selectedDataSource
{
	[self setSelectedDataSource:selectedDataSource animated:NO completionHandler:nil];
}


- (void)setSelectedDataSource:(APPSDataSource *)selectedDataSource animated:(BOOL)animated
{
	[self setSelectedDataSource:selectedDataSource animated:animated completionHandler:nil];
}


- (void)setSelectedDataSource:(APPSDataSource *)selectedDataSource animated:(BOOL)animated completionHandler:(dispatch_block_t)handler
{
	if (_selectedDataSource == selectedDataSource) {
		if (handler)
			handler();
		return;
	}
    
    NSAssert([_dataSources containsObject:selectedDataSource], @"selected data source must be contained in this data source");

	APPSDataSource *oldDataSource = _selectedDataSource;
	NSInteger numberOfOldSections = oldDataSource.numberOfSections;
	NSInteger numberOfNewSections = selectedDataSource.numberOfSections;
	
	NSIndexSet *removedSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, numberOfOldSections)];
	NSIndexSet *insertedSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, numberOfNewSections)];
	
	// Update the sections all at once.
    [self performUpdate:^{
        [oldDataSource willResignActive];

        if (removedSet)
			[self notifySectionsRemoved:removedSet];
        
        [self willChangeValueForKey:@"selectedDataSource"];
        [self willChangeValueForKey:@"selectedDataSourceIndex"];
        
        _selectedDataSource = selectedDataSource;
        
        [self didChangeValueForKey:@"selectedDataSource"];
        [self didChangeValueForKey:@"selectedDataSourceIndex"];
        
		if (insertedSet)
			[self notifySectionsInserted:insertedSet];
        
        [selectedDataSource didBecomeActive];
	} complete:handler];
	
}


- (NSArray *)indexPathsForItem:(id)object
{
    return [_selectedDataSource indexPathsForItem:object];
}


- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return [_selectedDataSource itemAtIndexPath:indexPath];
}


- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath
{
    [_selectedDataSource removeItemAtIndexPath:indexPath];
}


- (void)didBecomeActive
{
    [super didBecomeActive];
    [_selectedDataSource didBecomeActive];
}


- (void)willResignActive
{
    [super willResignActive];
    [_selectedDataSource willResignActive];
}


- (BOOL)allowsSelection
{
    return [_selectedDataSource allowsSelection];
}


- (void)configureSegmentedControl:(UISegmentedControl *)segmentedControl
{
    NSArray *titles = [self.dataSources valueForKey:@"title"];
    
    [segmentedControl removeAllSegments];
    [titles enumerateObjectsUsingBlock:^(NSString *segmentTitle, NSUInteger segmentIndex, BOOL *stop) {
        if ([segmentTitle isEqual:[NSNull null]])
            segmentTitle = @"NULL";
        [segmentedControl insertSegmentWithTitle:segmentTitle atIndex:segmentIndex animated:NO];
    }];
    [segmentedControl addTarget:self action:@selector(selectedSegmentIndexChanged:) forControlEvents:UIControlEventValueChanged];
    segmentedControl.selectedSegmentIndex = self.selectedDataSourceIndex;
}


- (void)registerReusableViewsWithTableView:(UITableView *)tableView
{
    [super registerReusableViewsWithTableView:tableView];
    
    for (APPSDataSource *dataSource in self.dataSources)
        [dataSource registerReusableViewsWithTableView:tableView];
}



#pragma mark - Protocol: APPSContentLoading

- (void)beginLoadingContentWithProgress:(APPSLoadingProgress *)progress
{
    // Only load the currently selected data source. Others will be loaded as necessary.
    [_selectedDataSource loadContent];
    
    // Make certain we call super to ensure the correct behaviour still occurs for this data source.
    [super beginLoadingContentWithProgress:progress];
}

- (void)resetContent
{
    for (APPSDataSource *dataSource in self.dataSources)
        [dataSource resetContent];
    [super resetContent];
}






#pragma mark - Placeholders

- (void)updatePlaceholderView:(APPSTablePlaceholderView *)placeholderView forSectionAtIndex:(NSInteger)sectionIndex
{
    [_selectedDataSource updatePlaceholderView:placeholderView forSectionAtIndex:sectionIndex];
}



#pragma mark - Header action method

- (void)selectedSegmentIndexChanged:(id)sender
{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    if (![segmentedControl isKindOfClass:[UISegmentedControl class]])
        return;
    
    segmentedControl.userInteractionEnabled = NO;
    NSInteger selectedSegmentIndex = segmentedControl.selectedSegmentIndex;
    APPSDataSource *dataSource = self.dataSources[selectedSegmentIndex];
    [self setSelectedDataSource:dataSource animated:YES completionHandler:^{
        segmentedControl.userInteractionEnabled = YES;
    }];
}



#pragma mark - Protocol: UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // When we're showing a placeholder, we have to lie to the collection view about the number of items we have. Otherwise, it will ask for layout attributes that we don't have.
    return self.shouldShowPlaceholder ? 0 : [_selectedDataSource tableView:tableView numberOfRowsInSection:section];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [_selectedDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if ([_selectedDataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
		return [_selectedDataSource tableView:tableView titleForHeaderInSection:section];
	} else {
		return nil;
	}
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if ([_selectedDataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)]) {
		return [_selectedDataSource tableView:tableView titleForFooterInSection:section];
	} else {
		return nil;
	}
}



#pragma mark - Protocol: APPSDataSourceDelegate

- (void)dataSource:(APPSDataSource *)dataSource didInsertItemsAtIndexPaths:(NSArray *)indexPaths
{
	if (dataSource != _selectedDataSource)
		return;
	
	[self notifyItemsInsertedAtIndexPaths:indexPaths];
}


- (void)dataSource:(APPSDataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)indexPaths
{
	if (dataSource != _selectedDataSource)
		return;
	
	[self notifyItemsRemovedAtIndexPaths:indexPaths];
}


- (void)dataSource:(APPSDataSource *)dataSource didRefreshItemsAtIndexPaths:(NSArray *)indexPaths
{
	if (dataSource != _selectedDataSource)
		return;
	
	[self notifyItemsRefreshedAtIndexPaths:indexPaths];
}


- (void)dataSource:(APPSDataSource *)dataSource didMoveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)newIndexPath
{
	if (dataSource != _selectedDataSource)
		return;
	
	[self notifyItemMovedFromIndexPath:fromIndexPath toIndexPaths:newIndexPath];
}


- (void)dataSource:(APPSDataSource *)dataSource didInsertSections:(NSIndexSet *)sections
{
	if (dataSource != _selectedDataSource)
		return;
	
	[self notifySectionsInserted:sections];
}


- (void)dataSource:(APPSDataSource *)dataSource didRemoveSections:(NSIndexSet *)sections
{
	if (dataSource != _selectedDataSource)
		return;
	
	[self notifySectionsRemoved:sections];
}


- (void)dataSource:(APPSDataSource *)dataSource didRefreshSections:(NSIndexSet *)sections
{
	if (dataSource != _selectedDataSource)
		return;
	
	[self notifySectionsRefreshed:sections];
}


- (void)dataSource:(APPSDataSource *)dataSource didMoveSection:(NSInteger)section toSection:(NSInteger)newSection
{
	if (dataSource != _selectedDataSource)
		return;
	
	[self notifySectionMovedFrom:section to:newSection];
}


- (void)dataSourceDidReloadData:(APPSDataSource *)dataSource
{
	if (dataSource != _selectedDataSource)
		return;
	
	[self notifyDidReloadData];
}


- (void)dataSource:(APPSDataSource *)dataSource performBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete
{
	if (dataSource != _selectedDataSource) {
        // This isn't the active data source, so just go ahead and update it, because the changes won't be reflected in the table view.
		if (update)
			update();
		if (complete)
			complete();
		return;
	}
	
    [self performUpdate:update complete:complete];
}


- (void)dataSource:(APPSDataSource *)dataSource didPresentActivityIndicatorForSections:(NSIndexSet *)sections
{
    if (dataSource != _selectedDataSource)
        return;
    
    [self presentActivityIndicatorForSections:sections];
}


/// Present a placeholder for a set of sections. The sections must be contiguous.
- (void)dataSource:(APPSDataSource *)dataSource didPresentPlaceholderForSections:(NSIndexSet *)sections
{
    if (dataSource != _selectedDataSource)
        return;
    
    [self presentPlaceholder:nil forSections:sections];
}


/// Remove a placeholder for a set of sections.
- (void)dataSource:(APPSDataSource *)dataSource didDismissPlaceholderForSections:(NSIndexSet *)sections
{
    if (dataSource != _selectedDataSource)
        return;
    
    [self dismissPlaceholderForSections:sections];
}


@end
