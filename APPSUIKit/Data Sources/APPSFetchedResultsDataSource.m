//
//  APPSFetchedResultsDataSource.m
//
//  Created by Ken Grigsby on 10/6/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import "APPSFetchedResultsDataSource.h"
#import "APPSDataSource_Private.h"


@interface APPSFetchedResultsDataSource () <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, copy) dispatch_block_t pendingChangeBlock;
@end

@implementation APPSFetchedResultsDataSource


#pragma mark - Instantiation

- (instancetype) init
{
    return [self initWithFetchedResultsController:nil];
}


- (instancetype) initWithFetchedResultsController:(NSFetchedResultsController *)frc
{
    self = [super init];
    if (self) {
        _fetchedResultsController = frc;
        _fetchedResultsController.delegate = self;
    }
    return self;
}



#pragma mark - APPSDataSource

- (NSInteger)numberOfSections
{
    return self.fetchedResultsController.sections.count;
}


- (NSInteger)numberOfRowsInSection:(NSInteger)sectionIndex
{
    return [[[self.fetchedResultsController sections] objectAtIndex:sectionIndex] numberOfObjects];
}


- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}


- (NSArray *)indexPathsForItem:(id)item
{
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:item];
    return indexPath ? @[indexPath] : nil;
}


- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath
{
    id obj = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.fetchedResultsController.managedObjectContext deleteObject:obj];
}



#pragma mark - Protocol: APPSContentLoading

- (void)loadContentWithProgress:(APPSLoadingProgress *)progress
{
    if (progress.cancelled)
        return;
    
    NSError *error;
    BOOL success = [self.fetchedResultsController performFetch:&error];
    [self notifyDidReloadData]; // Sync the tableView
    
    if (!success) {
        [progress doneWithError:error];
    }
    else if (self.fetchedResultsController.fetchedObjects.count > 0) {
        [progress updateWithContent:^(APPSFetchedResultsDataSource *me) {
        }];
    }
    else {
        [progress updateWithNoContent:^(APPSFetchedResultsDataSource *me) {
        }];
    }
    
}


- (void)updateLoadingStateFromItems
{
    NSString *loadingState = self.loadingState;
    NSUInteger numberOfItems = self.fetchedResultsController.fetchedObjects.count;
    if (numberOfItems && [loadingState isEqualToString:APPSLoadStateNoContent])
        self.loadingState = APPSLoadStateContentLoaded;
    else if (!numberOfItems && [loadingState isEqualToString:APPSLoadStateContentLoaded])
        self.loadingState = APPSLoadStateNoContent;
}



#pragma mark - Protocol: UITableViewDataSource

- (void)willChangeContent
{
}


- (void)didChangeContent
{
    [self performUpdate:self.pendingChangeBlock];
    self.pendingChangeBlock = nil;
}


#pragma mark - Protocol: NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self willChangeContent];
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self didChangeContent];
}


- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    __weak typeof(self) weakSelf = self;
    
    [self enqueueChangeBlock:^{
        
        
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [self updateLoadingStateFromItems];
                [weakSelf notifySectionsInserted:[NSIndexSet indexSetWithIndex:sectionIndex]];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self updateLoadingStateFromItems];
                [weakSelf notifySectionsRemoved:[NSIndexSet indexSetWithIndex:sectionIndex]];
                break;
                
            default:
                NSLog(@"Unsupported type: %lu", (unsigned long)type);
                break;
        }
    }];
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    __weak typeof(self) weakSelf = self;
    
    [self enqueueChangeBlock:^{
 
        switch(type) {
                
            case NSFetchedResultsChangeInsert:
                [self updateLoadingStateFromItems];
                [weakSelf notifyItemsInsertedAtIndexPaths:@[newIndexPath]];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self updateLoadingStateFromItems];
                [weakSelf notifyItemsRemovedAtIndexPaths:@[indexPath]];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [weakSelf notifyItemsRefreshedAtIndexPaths:@[indexPath]];
                break;
                
            case NSFetchedResultsChangeMove:
                [weakSelf notifyItemMovedFromIndexPath:indexPath toIndexPaths:newIndexPath];
                break;
        }
    }];
}


- (void)enqueueChangeBlock:(dispatch_block_t)block
{
    dispatch_block_t update;
    
    if (_pendingChangeBlock) {
        dispatch_block_t oldPendingUpdate = _pendingChangeBlock;
        update = ^{
            oldPendingUpdate();
            block();
        };
    }
    else
        update = block;
    
    self.pendingChangeBlock = update;
}

@end
