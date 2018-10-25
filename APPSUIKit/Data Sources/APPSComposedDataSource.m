//
//  APPSComposedDataSource.m
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

#import "APPSDataSource_Private.h"
#import "APPSComposedDataSource.h"
#import "APPSDataSourceMapping.h"
#import "APPSPlaceholderView.h"

@interface APPSComposedDataSource () <APPSDataSourceDelegate>
@property (nonatomic, strong) NSMutableArray *mappings;
@property (nonatomic, strong) NSMapTable *dataSourceToMappings;
@property (nonatomic, strong) NSMutableDictionary *globalSectionToMappings;
@end

@implementation APPSComposedDataSource {
    NSInteger _numberOfSections;
}


#pragma mark - Instantiation

- (instancetype)init
{
	self = [super init];
	if (!self)
		return nil;
	
    _mappings = [[NSMutableArray alloc] init];
    _dataSourceToMappings = [[NSMapTable alloc] initWithKeyOptions:NSMapTableObjectPointerPersonality valueOptions:NSMapTableStrongMemory capacity:1];
    _globalSectionToMappings = [[NSMutableDictionary alloc] init];
	
	return self;
}


- (void)updateMappings
{
    _numberOfSections = 0;
    [_globalSectionToMappings removeAllObjects];
    
    for (APPSDataSourceMapping *mapping in _mappings) {
        [mapping updateMappingStartingAtGlobalSection:_numberOfSections withBlock:^(NSInteger sectionIndex) {
            _globalSectionToMappings[@(sectionIndex)] = mapping;
        }];
        _numberOfSections += mapping.numberOfSections;
    }
}


- (NSUInteger)sectionForDataSource:(APPSDataSource *)dataSource
{
    APPSDataSourceMapping *mapping = [self mappingForDataSource:dataSource];
    
    return [mapping globalSectionForLocalSection:0];
}


- (APPSDataSource *)dataSourceForSectionAtIndex:(NSInteger)sectionIndex
{
    APPSDataSourceMapping *mapping = _globalSectionToMappings[@(sectionIndex)];
    return mapping.dataSource;
}


- (NSIndexPath *)localIndexPathForGlobalIndexPath:(NSIndexPath *)globalIndexPath
{
    APPSDataSourceMapping *mapping = [self mappingForGlobalSection:globalIndexPath.section];
    return [mapping localIndexPathForGlobalIndexPath:globalIndexPath];
}


- (APPSDataSourceMapping *)mappingForGlobalSection:(NSInteger)section
{
    APPSDataSourceMapping *mapping = _globalSectionToMappings[@(section)];
    return mapping;
}


- (APPSDataSourceMapping *)mappingForDataSource:(APPSDataSource *)dataSource
{
    APPSDataSourceMapping *mapping = [_dataSourceToMappings objectForKey:dataSource];
    return mapping;
}


- (NSIndexSet *)globalSectionsForLocal:(NSIndexSet *)localSections dataSource:(APPSDataSource *)dataSource
{
    NSMutableIndexSet *result = [NSMutableIndexSet indexSet];
    APPSDataSourceMapping *mapping = [self mappingForDataSource:dataSource];
    [localSections enumerateIndexesUsingBlock:^(NSUInteger localSection, BOOL *stop) {
        [result addIndex:[mapping globalSectionForLocalSection:localSection]];
    }];
    return result;
}


- (NSArray *)globalIndexPathsForLocal:(NSArray *)localIndexPaths dataSource:(APPSDataSource *)dataSource
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[localIndexPaths count]];
    APPSDataSourceMapping *mapping = [self mappingForDataSource:dataSource];
    for (NSIndexPath *localIndexPath in localIndexPaths) {
        [result addObject:[mapping globalIndexPathForLocalIndexPath:localIndexPath]];
    }
    
    return result;
}


- (void)enumerateDataSourcesWithBlock:(void(^)(APPSDataSource *dataSource, BOOL *stop))block
{
    NSParameterAssert(block != nil);
    
    BOOL stop = NO;
    for (id key in _dataSourceToMappings) {
        APPSDataSourceMapping *mapping = [_dataSourceToMappings objectForKey:key];
        block(mapping.dataSource, &stop);
        if (stop)
            break;
    }
}


- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    APPSDataSourceMapping *mapping = [self mappingForGlobalSection:indexPath.section];
    
    NSIndexPath *mappedIndexPath = [mapping localIndexPathForGlobalIndexPath:indexPath];
    
    return [mapping.dataSource itemAtIndexPath:mappedIndexPath];
}


- (NSArray*)indexPathsForItem:(id)object
{
    NSMutableArray *results = [NSMutableArray array];
    
    [self enumerateDataSourcesWithBlock:^(APPSDataSource *dataSource, BOOL *stop) {
        APPSDataSourceMapping *mapping = [self mappingForDataSource:dataSource];
        NSArray *indexPaths = [dataSource indexPathsForItem:object];
        
        if (![indexPaths count])
            return;
        
        for (NSIndexPath *localIndexPath in indexPaths)
            [results addObject:[mapping globalIndexPathForLocalIndexPath:localIndexPath]];
    }];
    
    return results;
}


- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath
{
    APPSDataSourceMapping *mapping = [self mappingForGlobalSection:indexPath.section];
    APPSDataSource *dataSource = mapping.dataSource;
    NSIndexPath *localIndexPath = [mapping localIndexPathForGlobalIndexPath:indexPath];
    
    [dataSource removeItemAtIndexPath:localIndexPath];
}


- (void)didBecomeActive
{
    [super didBecomeActive];
    [self enumerateDataSourcesWithBlock:^(APPSDataSource *dataSource, BOOL *stop) {
        [dataSource didBecomeActive];
    }];
}

- (void)willResignActive
{
    [super willResignActive];
    [self enumerateDataSourcesWithBlock:^(APPSDataSource *dataSource, BOOL *stop) {
        [dataSource willResignActive];
    }];
}

- (void)presentActivityIndicatorForSections:(NSIndexSet *)sections
{
    // Based on the rule that if any child is loading, the composed data source is loading, we're going to expand the sections to cover the entire data source if any child asks for an activity indicator AND we're loading.
    if ([self.loadingState isEqualToString:APPSLoadStateLoadingContent])
        sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.numberOfSections)];
    
    [super presentActivityIndicatorForSections:sections];
}

- (void)updatePlaceholderView:(APPSTablePlaceholderView *)placeholderView forSectionAtIndex:(NSInteger)sectionIndex
{
    // Need to determine which data source gets a crack at updating the placeholder
    
    // If the sectionIndex is 0 and we're going to show an activity indicator, let the super class handle it. Although, sectionIndex probably shouldn't ever be anything BUT 0 when we're going to show an activity indicator.
    if (0 == sectionIndex && self.shouldShowActivityIndicator) {
        [super updatePlaceholderView:placeholderView forSectionAtIndex:sectionIndex];
        return;
    }
    
    // If this data source is showing a placeholder and the sectionIndex is 0, allow the super class to handle it. It's probably an error if we get a sectionIndex other than 0.
    if (0 == sectionIndex && self.shouldShowPlaceholder) {
        [super updatePlaceholderView:placeholderView forSectionAtIndex:sectionIndex];
        return;
    }
    
    // This data source doesn't want to handle the placeholder. Find a child data source that should.
    APPSDataSourceMapping *mapping = [self mappingForGlobalSection:sectionIndex];
    APPSDataSource *dataSource = mapping.dataSource;
    NSInteger localSectionIndex = [mapping localSectionForGlobalSection:sectionIndex];
    [dataSource updatePlaceholderView:placeholderView forSectionAtIndex:localSectionIndex];
}



#pragma mark - APPSComposedDataSource API

- (void)addDataSource:(APPSDataSource *)dataSource
{
    NSParameterAssert(dataSource != nil);
    
    dataSource.delegate = self;
    
    APPSDataSourceMapping *mappingForDataSource = [_dataSourceToMappings objectForKey:dataSource];
    NSAssert(mappingForDataSource == nil, @"tried to add data source more than once: %@", dataSource);
    
    mappingForDataSource = [[APPSDataSourceMapping alloc] initWithDataSource:dataSource];
    [_mappings addObject:mappingForDataSource];
    [_dataSourceToMappings setObject:mappingForDataSource forKey:dataSource];
    
    [self updateMappings];
    NSMutableIndexSet *addedSections = [NSMutableIndexSet indexSet];
    NSUInteger numberOfSections = dataSource.numberOfSections;
    
    for (NSUInteger sectionIdx = 0; sectionIdx < numberOfSections; ++sectionIdx)
        [addedSections addIndex:[mappingForDataSource globalSectionForLocalSection:sectionIdx]];
    [self notifySectionsInserted:addedSections];
}

- (void)removeDataSource:(APPSDataSource *)dataSource
{
    APPSDataSourceMapping *mappingForDataSource = [_dataSourceToMappings objectForKey:dataSource];
    NSAssert(mappingForDataSource != nil, @"Data source not found in mapping");
    
    NSMutableIndexSet *removedSections = [NSMutableIndexSet indexSet];
    NSUInteger numberOfSections = dataSource.numberOfSections;
    
    for (NSUInteger sectionIdx = 0; sectionIdx < numberOfSections; ++sectionIdx)
        [removedSections addIndex:[mappingForDataSource globalSectionForLocalSection:sectionIdx]];
    
    [_dataSourceToMappings removeObjectForKey:dataSource];
    [_mappings removeObject:mappingForDataSource];
    
    dataSource.delegate = nil;
    
    [self updateMappings];
    
    [self notifySectionsRemoved:removedSections];
}



#pragma mark - APPSDataSource methods

- (NSInteger)numberOfSections
{
    [self updateMappings];
    return _numberOfSections;
}


- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
    APPSDataSourceMapping *mapping = [self mappingForGlobalSection:section];
    NSInteger localSection = [mapping localSectionForGlobalSection:section];
    
    return [mapping.dataSource numberOfRowsInSection:localSection];
}


- (void)registerReusableViewsWithTableView:(UITableView *)tableView
{
	[super registerReusableViewsWithTableView:tableView];
	
    [self enumerateDataSourcesWithBlock:^(APPSDataSource *dataSource, BOOL *stop) {
        [dataSource registerReusableViewsWithTableView:tableView];
    }];
}



#pragma mark - Protocol: APPSContentLoading

- (void)endLoadingContentWithState:(NSString *)state error:(NSError *)error update:(dispatch_block_t)update
{
    // For composed data sources, if a subclass implements -loadContentWithProgress: and reports a final state of APPSLoadStateNoContent or APPSLoadStateError, it doesn't matter what our children report. We're done.
    if ([APPSLoadStateNoContent isEqualToString:state] || [APPSLoadStateError isEqualToString:state]) {
        [super endLoadingContentWithState:state error:error update:update];
        return;
    }
    
    // That means we should be in APPSLoadStateContentLoaded now…
    NSAssert([APPSLoadStateContentLoaded isEqualToString:state], @"We're in an unexpected state: %@", state);
    
    // We need to wait for all the loading child data sources to complete
    dispatch_group_t loadingGroup = dispatch_group_create();
    [self enumerateDataSourcesWithBlock:^(APPSDataSource *dataSource, BOOL *stop) {
        NSString *loadingState = dataSource.loadingState;
        // Skip data sources that aren't loading
        if (![APPSLoadStateLoadingContent isEqualToString:loadingState] && ![APPSLoadStateRefreshingContent isEqualToString:loadingState])
            return;
        
        dispatch_group_enter(loadingGroup);
        [dataSource whenLoaded:^{
            dispatch_group_leave(loadingGroup);
        }];
    }];
    
    // When all the child data sources have loaded, we need to figure out what the result state is.
    dispatch_group_notify(loadingGroup, dispatch_get_main_queue(), ^{
        NSMutableSet *resultSet = [NSMutableSet set];
        [self enumerateDataSourcesWithBlock:^(APPSDataSource *dataSource, BOOL *stop) {
            [resultSet addObject:dataSource.loadingState];
        }];
        
        NSString *finalState = state;
        
        // resultSet will hold the deduplicated set of loading states. We want to be a bit clever here. If all the data sources yielded no content, we should transition to no content regardless of what our loading result was. Otherwise, we'll transition to content loaded and allow each child data source to present its own placeholder as appropriate.
        if (1 == resultSet.count && [APPSLoadStateNoContent isEqualToString:resultSet.anyObject])
            finalState = APPSLoadStateNoContent;
        
        [super endLoadingContentWithState:finalState error:error update:update];
    });
}

- (void)beginLoadingContentWithProgress:(APPSLoadingProgress *)progress
{
    // Before we start loading any content for the composed data source itself, make certain all the child data sources have started loading.
    [self enumerateDataSourcesWithBlock:^(APPSDataSource *dataSource, BOOL *stop) {
        [dataSource loadContent];
    }];
    
    [self loadContentWithProgress:progress];
}

- (void)resetContent
{
    [super resetContent];
    [self enumerateDataSourcesWithBlock:^(APPSDataSource *dataSource, BOOL *stop) {
        [dataSource resetContent];
    }];
}



#pragma mark - Protocol: UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	[self updateMappings];
	
    // When we're showing a placeholder, we have to lie to the table view about the number of items we have. Otherwise, it will ask for layout attributes that we don't have.
    if (self.shouldShowPlaceholder)
        return 0;
    
	APPSDataSourceMapping *mapping = [self mappingForGlobalSection:section];
	NSInteger localSection = [mapping localSectionForGlobalSection:section];
	APPSDataSource *dataSource = mapping.dataSource;

#if !defined(NS_BLOCK_ASSERTIONS)
    NSInteger numberOfSections = [dataSource numberOfSectionsInTableView:tableView];
    NSAssert(localSection < numberOfSections, @"local section is out of bounds for composed data source");
#endif
    
	return [dataSource tableView:tableView numberOfRowsInSection:localSection];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	APPSDataSourceMapping *mapping = [self mappingForGlobalSection:indexPath.section];
	APPSDataSource *dataSource = mapping.dataSource;
	NSIndexPath *localIndexPath = [mapping localIndexPathForGlobalIndexPath:indexPath];
	
	return [dataSource tableView:tableView cellForRowAtIndexPath:localIndexPath];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	APPSDataSourceMapping *mapping = [self mappingForGlobalSection:section];
	APPSDataSource *dataSource = mapping.dataSource;
    NSUInteger localSection = [mapping localSectionForGlobalSection:section];

    if ([dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
        return [dataSource tableView:tableView titleForHeaderInSection:localSection];
    } else {
        return nil;
    }
}


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	APPSDataSourceMapping *mapping = [self mappingForGlobalSection:section];
	APPSDataSource *dataSource = mapping.dataSource;
    NSUInteger localSection = [mapping localSectionForGlobalSection:section];

    if ([dataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)]) {
        return [dataSource tableView:tableView titleForFooterInSection:localSection];
    } else {
        return nil;
    }
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    APPSDataSourceMapping *mapping = [self mappingForGlobalSection:indexPath.section];
    APPSDataSource *dataSource = mapping.dataSource;
    NSIndexPath *localIndexPath = [mapping localIndexPathForGlobalIndexPath:indexPath];
    
    if ([dataSource respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)]) {
        return[dataSource tableView:tableView canEditRowAtIndexPath:localIndexPath];
    }
    else {
        return YES;
    }
}



#pragma mark - Protocol: APPSDataSourceDelegate

- (void)dataSource:(APPSDataSource *)dataSource didInsertItemsAtIndexPaths:(NSArray *)indexPaths
{
	APPSDataSourceMapping *mapping = [self mappingForDataSource:dataSource];
	NSArray *globalIndexPaths = [mapping globalIndexPathsForLocalIndexPaths:indexPaths];
	
	[self notifyItemsInsertedAtIndexPaths:globalIndexPaths];
}


- (void)dataSource:(APPSDataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)indexPaths
{
	APPSDataSourceMapping *mapping = [self mappingForDataSource:dataSource];
	NSArray *globalIndexPaths = [mapping globalIndexPathsForLocalIndexPaths:indexPaths];
	
	[self notifyItemsRemovedAtIndexPaths:globalIndexPaths];
}


- (void)dataSource:(APPSDataSource *)dataSource didRefreshItemsAtIndexPaths:(NSArray *)indexPaths
{
	APPSDataSourceMapping *mapping = [self mappingForDataSource:dataSource];
	NSArray *globalIndexPaths = [mapping globalIndexPathsForLocalIndexPaths:indexPaths];
	
	[self notifyItemsRefreshedAtIndexPaths:globalIndexPaths];
}


- (void)dataSource:(APPSDataSource *)dataSource didMoveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)newIndexPath
{
	APPSDataSourceMapping *mapping = [self mappingForDataSource:dataSource];
	NSIndexPath *globalFromIndexPath = [mapping globalIndexPathForLocalIndexPath:fromIndexPath];
	NSIndexPath *globalNewIndexPath = [mapping globalIndexPathForLocalIndexPath:newIndexPath];
	
	[self notifyItemMovedFromIndexPath:globalFromIndexPath toIndexPaths:globalNewIndexPath];
}


- (void)dataSource:(APPSDataSource *)dataSource didInsertSections:(NSIndexSet *)sections
{
	APPSDataSourceMapping *mapping = [self mappingForDataSource:dataSource];
	
	[self updateMappings];
	
	NSMutableIndexSet *globalSections = [NSMutableIndexSet indexSet];
	[sections enumerateIndexesUsingBlock:^(NSUInteger localSectionIndex, BOOL *stop) {
		[globalSections addIndex:[mapping globalSectionForLocalSection:localSectionIndex]];
	}];
	
	[self notifySectionsInserted:globalSections];
}


- (void)dataSource:(APPSDataSource *)dataSource didRemoveSections:(NSIndexSet *)sections
{
	APPSDataSourceMapping *mapping = [self mappingForDataSource:dataSource];
	
	[self updateMappings];
	
	NSMutableIndexSet *globalSections = [NSMutableIndexSet indexSet];
	[sections enumerateIndexesUsingBlock:^(NSUInteger localSectionIndex, BOOL *stop) {
		[globalSections addIndex:[mapping globalSectionForLocalSection:localSectionIndex]];
	}];
	
	[self notifySectionsRemoved:globalSections];
}


- (void)dataSource:(APPSDataSource *)dataSource didRefreshSections:(NSIndexSet *)sections
{
	APPSDataSourceMapping *mapping = [self mappingForDataSource:dataSource];
	
	NSMutableIndexSet *globalSections = [NSMutableIndexSet indexSet];
	[sections enumerateIndexesUsingBlock:^(NSUInteger localSectionIndex, BOOL *stop) {
		[globalSections addIndex:[mapping globalSectionForLocalSection:localSectionIndex]];
	}];
	
	[self notifySectionsRefreshed:globalSections];
	[self updateMappings];
}


- (void)dataSource:(APPSDataSource *)dataSource didMoveSection:(NSInteger)section toSection:(NSInteger)newSection
{
	APPSDataSourceMapping *mapping = [self mappingForDataSource:dataSource];
	
	NSInteger globalSection = [mapping globalSectionForLocalSection:section];
	NSInteger globalNewSection = [mapping globalSectionForLocalSection:newSection];
	
	[self updateMappings];
	
	[self notifySectionMovedFrom:globalSection to:globalNewSection];
}


- (void)dataSourceDidReloadData:(APPSDataSource *)dataSource
{
	[self notifyDidReloadData];
}


- (void)dataSource:(APPSDataSource *)dataSource performBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete
{
    [self performUpdate:update complete:complete];
}


- (void)dataSource:(APPSDataSource *)dataSource didPresentActivityIndicatorForSections:(NSIndexSet *)sections
{
    APPSDataSourceMapping *mapping = [self mappingForDataSource:dataSource];
    
    NSMutableIndexSet *globalSections = [NSMutableIndexSet indexSet];
    [sections enumerateIndexesUsingBlock:^(NSUInteger localSectionIndex, BOOL *stop) {
        [globalSections addIndex:[mapping globalSectionForLocalSection:localSectionIndex]];
    }];
    
    [self presentActivityIndicatorForSections:globalSections];
}

/// Present a placeholder for a set of sections. The sections must be contiguous.
- (void)dataSource:(APPSDataSource *)dataSource didPresentPlaceholderForSections:(NSIndexSet *)sections
{
    APPSDataSourceMapping *mapping = [self mappingForDataSource:dataSource];
    
    NSMutableIndexSet *globalSections = [NSMutableIndexSet indexSet];
    [sections enumerateIndexesUsingBlock:^(NSUInteger localSectionIndex, BOOL *stop) {
        [globalSections addIndex:[mapping globalSectionForLocalSection:localSectionIndex]];
    }];
    
    [self presentPlaceholder:nil forSections:globalSections];
}

/// Remove a placeholder for a set of sections.
- (void)dataSource:(APPSDataSource *)dataSource didDismissPlaceholderForSections:(NSIndexSet *)sections
{
    APPSDataSourceMapping *mapping = [self mappingForDataSource:dataSource];
    
    NSMutableIndexSet *globalSections = [NSMutableIndexSet indexSet];
    [sections enumerateIndexesUsingBlock:^(NSUInteger localSectionIndex, BOOL *stop) {
        [globalSections addIndex:[mapping globalSectionForLocalSection:localSectionIndex]];
    }];
    
    [self dismissPlaceholderForSections:globalSections];
}




@end
