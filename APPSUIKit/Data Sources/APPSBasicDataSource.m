//
//  APPSBasicDataSource.m
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
 A subclass of APPSDataSource which permits only one section but manages its items in an NSArray. This class will perform all the necessary updates to animate changes to the array of items if they are updated using -setItems:animated:.
 */

#import "APPSBasicDataSource.h"


@implementation APPSBasicDataSource


#pragma mark - APPSDataSource

- (instancetype)init
{
    self = [super init];
    if (!self)
        return nil;
    _items = @[];
    return self;
}

- (void)resetContent
{
    [super resetContent];
    [self performUpdate:^{
        self.items = @[];
    }];
}


- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
	NSUInteger itemIndex = indexPath.row;
	if (itemIndex < [_items count])
		return _items[itemIndex];
	
	return nil;
}


- (NSArray *)indexPathsForItem:(id)item
{
	NSMutableArray *indexPaths = [NSMutableArray array];
	[_items enumerateObjectsUsingBlock:^(id obj, NSUInteger objectIndex, BOOL *stop) {
		if ([obj isEqual:item])
			[indexPaths addObject:[NSIndexPath indexPathForItem:objectIndex inSection:0]];
	}];
	return indexPaths;
}


- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSIndexSet *removedIndexes = [NSIndexSet indexSetWithIndex:indexPath.item];
	[self removeItemsAtIndexes:removedIndexes];
}



#pragma mark - Property Overrides

- (void)setItems:(NSArray *)items
{
	[self setItems:items animated:NO];
}


- (void)setItems:(NSArray *)items animated:(BOOL)animated
{
	if (_items == items || [_items isEqualToArray:items])
		return;
	
    APPS_ASSERT_IN_DATASOURCE_UPDATE();

	if (!animated) {
		_items = [items copy];
		[self updateLoadingStateFromItems];
		[self notifySectionsRefreshed:[NSIndexSet indexSetWithIndex:0]];
		return;
	}
	
	NSOrderedSet *oldItemSet = [NSOrderedSet orderedSetWithArray:_items];
	NSOrderedSet *newItemSet = [NSOrderedSet orderedSetWithArray:items];
	
	NSMutableOrderedSet *deletedItems = [oldItemSet mutableCopy];
	[deletedItems minusOrderedSet:newItemSet];
	
	NSMutableOrderedSet *newItems = [newItemSet mutableCopy];
	[newItems minusOrderedSet:oldItemSet];
	
	NSMutableOrderedSet *movedItems = [newItemSet mutableCopy];
	[movedItems intersectOrderedSet:oldItemSet];
	
	NSMutableArray *deletedIndexPaths = [NSMutableArray arrayWithCapacity:[deletedItems count]];
	for (id deletedItem in deletedItems) {
		[deletedIndexPaths addObject:[NSIndexPath indexPathForItem:[oldItemSet indexOfObject:deletedItem] inSection:0]];
	}
	
	NSMutableArray *insertedIndexPaths = [NSMutableArray arrayWithCapacity:[newItems count]];
	for (id newItem in newItems) {
		[insertedIndexPaths addObject:[NSIndexPath indexPathForItem:[newItemSet indexOfObject:newItem] inSection:0]];
	}
	
	NSMutableArray *fromMovedIndexPaths = [NSMutableArray arrayWithCapacity:[movedItems count]];
	NSMutableArray *toMovedIndexPaths = [NSMutableArray arrayWithCapacity:[movedItems count]];
	for (id movedItem in movedItems) {
		[fromMovedIndexPaths addObject:[NSIndexPath indexPathForItem:[oldItemSet indexOfObject:movedItem] inSection:0]];
		[toMovedIndexPaths addObject:[NSIndexPath indexPathForItem:[newItemSet indexOfObject:movedItem] inSection:0]];
	}
	
	_items = [items copy];
	[self updateLoadingStateFromItems];
	
    
    if ([deletedIndexPaths count])
        [self notifyItemsRemovedAtIndexPaths:deletedIndexPaths];
    
    if ([insertedIndexPaths count])
        [self notifyItemsInsertedAtIndexPaths:insertedIndexPaths];
    
    NSUInteger count = [fromMovedIndexPaths count];
    for (NSUInteger i = 0; i < count; ++i) {
        NSIndexPath *fromIndexPath = fromMovedIndexPaths[i];
        NSIndexPath *toIndexPath = toMovedIndexPaths[i];
        if (![fromIndexPath isEqual:toIndexPath])
            [self notifyItemMovedFromIndexPath:fromIndexPath toIndexPaths:toIndexPath];
    }
}


- (void)updateLoadingStateFromItems
{
	NSString *loadingState = self.loadingState;
	NSUInteger numberOfItems = [_items count];
	if (numberOfItems && [loadingState isEqualToString:APPSLoadStateNoContent])
		self.loadingState = APPSLoadStateContentLoaded;
	else if (!numberOfItems && [loadingState isEqualToString:APPSLoadStateContentLoaded])
		self.loadingState = APPSLoadStateNoContent;
}



#pragma mark - KVC methods for item property

- (NSUInteger)countOfItems
{
	return [_items count];
}


- (NSArray *)itemsAtIndexes:(NSIndexSet *)indexes
{
	return [_items objectsAtIndexes:indexes];
}


- (void)getItems:(__unsafe_unretained id *)buffer range:(NSRange)range
{
	return [_items getObjects:buffer range:range];
}


- (void)insertItems:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    NSMutableArray *newItems = [_items mutableCopy];
    [newItems insertObjects:array atIndexes:indexes];
    
    NSMutableArray *insertedIndexPaths = [NSMutableArray arrayWithCapacity:[indexes count]];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [insertedIndexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
    }];
    
    APPS_ASSERT_IN_DATASOURCE_UPDATE();
    
    _items = newItems;
    [self updateLoadingStateFromItems];
    [self notifyItemsInsertedAtIndexPaths:insertedIndexPaths];
}


- (void)removeItemsAtIndexes:(NSIndexSet *)indexes
{
	NSInteger newCount = [_items count] - [indexes count];
	NSMutableArray *newItems = [[NSMutableArray alloc] initWithCapacity:newCount];
	
	// set up a delayed set of batch update calls for later execution
	__block dispatch_block_t batchUpdates = ^{};
	batchUpdates = [batchUpdates copy];
	
	[_items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		dispatch_block_t oldUpdates = batchUpdates;
		if ([indexes containsIndex:idx]) {
			// we're removing this item
			batchUpdates = ^{
				oldUpdates();
				[self notifyItemsRemovedAtIndexPaths:@[[NSIndexPath indexPathForItem:idx inSection:0]]];
			};
		}
		else {
			// we're keeping this item
			NSUInteger newIdx = [newItems count];
			[newItems addObject:obj];
			batchUpdates = ^{
				oldUpdates();
				[self notifyItemMovedFromIndexPath:[NSIndexPath indexPathForItem:idx inSection:0] toIndexPaths:[NSIndexPath indexPathForItem:newIdx inSection:0]];
			};
		}
		batchUpdates = [batchUpdates copy];
	}];
	
    APPS_ASSERT_IN_DATASOURCE_UPDATE();
    
	_items = newItems;
    batchUpdates();
    [self updateLoadingStateFromItems];
}


- (void)replaceItemsAtIndexes:(NSIndexSet *)indexes withItems:(NSArray *)array
{
    NSMutableArray *newItems = [_items mutableCopy];
    [newItems replaceObjectsAtIndexes:indexes withObjects:array];
    
    NSMutableArray *replacedIndexPaths = [NSMutableArray arrayWithCapacity:[indexes count]];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [replacedIndexPaths addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
    }];
    
    APPS_ASSERT_IN_DATASOURCE_UPDATE();
    
    _items = newItems;
    [self notifyItemsRefreshedAtIndexPaths:replacedIndexPaths];
}


- (NSInteger)numberOfRowsInSection:(NSInteger)sectionIndex
{
    return _items.count;
}


#pragma mark - Protocol: UITableViewDataSource

- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSInteger fromIndex = indexPath.item;
    NSInteger toIndex = destinationIndexPath.item;
    
    if (fromIndex == toIndex)
        return;
    
    NSInteger numberOfItems = (NSInteger)[_items count];
    if (fromIndex >= numberOfItems)
        return;
    
    if (toIndex >= numberOfItems)
        toIndex = numberOfItems - 1;
    
    NSMutableArray *items = [_items mutableCopy];
    
    id movingObject = items[fromIndex];
    
    [items removeObjectAtIndex:fromIndex];
    [items insertObject:movingObject atIndex:toIndex];
    
    _items = items;
    [self notifyItemMovedFromIndexPath:indexPath toIndexPaths:destinationIndexPath];
}

@end
