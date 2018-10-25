//
//  APPSDataSource.m
//
//  Created by Ken Grigsby on 8/24/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The base data source class.
 */


#import "APPSDataSource_Private.h"
#import "APPSLoadableContentPlaceholderView.h"
#import <libkern/OSAtomic.h>
#import <stdatomic.h>

#if DEBUG
static void *APPSPerformUpdateQueueSpecificKey = "APPSPerformUpdateQueueSpecificKey";
#endif

#define APPS_ASSERT_MAIN_THREAD NSAssert([NSThread isMainThread], @"This method must be called on the main thread")

@implementation APPSDataSourcePlaceholder

- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message image:(UIImage *)image activityIndicator:(BOOL)activityIndicator
{
    NSParameterAssert(title != nil || message != nil || activityIndicator);
    
    self = [super init];
    if (!self)
        return nil;
    
    _title = [title copy];
    _message = [message copy];
    _image = image;
    _activityIndicator = activityIndicator;
    return self;
}

+ (instancetype)placeholderWithActivityIndicator
{
    return [[self alloc] initWithTitle:nil message:nil image:nil activityIndicator:YES];
}

+ (instancetype)placeholderWithTitle:(NSString *)title message:(NSString *)message image:(UIImage *)image
{
    return [[self alloc] initWithTitle:title message:message image:image activityIndicator:NO];
}

- (id)copyWithZone:(NSZone *)zone
{
    APPSDataSourcePlaceholder *copy = [[self.class alloc] initWithTitle:self.title message:self.message image:self.image activityIndicator:self.activityIndicator];
    return copy;
}

@end


@interface APPSLoadingProgress()
@property (nonatomic, readwrite, getter = isCancelled) BOOL cancelled;
@end


@interface APPSDataSource () <APPSStateMachineDelegate>
@property (nonatomic, strong) APPSLoadableContentStateMachine *stateMachine;
@property (nonatomic, strong) APPSTablePlaceholderView *placeholderView;
@property (nonatomic, copy) dispatch_block_t pendingUpdateBlock;
/// Chained completion handlers added externally via -whenLoaded:
@property (nonatomic, copy) dispatch_block_t loadingCompletionBlock;
@property (nonatomic, weak) APPSLoadingProgress *loadingProgress;
@property (nonatomic, copy) APPSDataSourcePlaceholder *placeholder;
@property (nonatomic) BOOL resettingContent;
@end

@implementation APPSDataSource

@synthesize loadingError = _loadingError;



#pragma mark - Instantiation

- (instancetype)init
{
    self = [super init];
    if (!self)
        return nil;
    
    _allowsSelection = YES;
    return self;
}


- (BOOL)isRootDataSource
{
    id delegate = self.delegate;
    return [delegate isKindOfClass:[APPSDataSource class]] ? NO : YES;
}


- (APPSDataSource *)dataSourceForSectionAtIndex:(NSInteger)sectionIndex
{
	return self;
}


- (NSIndexPath *)localIndexPathForGlobalIndexPath:(NSIndexPath *)globalIndexPath
{
	return globalIndexPath;
}


- (NSArray *)indexPathsForItem:(id)object
{
	NSAssert(NO, @"Should be implemented by subclasses");
	return nil;
}


- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
	NSAssert(NO, @"Should be implemented by subclasses");
	return nil;
}


- (void)removeItemAtIndexPath:(NSIndexPath *)indexPath
{
	NSAssert(NO, @"Should be implemented by subclasses");
	return;
}


- (NSInteger)numberOfSections
{
	return 1;
}


- (NSInteger)numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 0;
}


- (void)registerReusableViewsWithTableView:(UITableView *)tableView
{
}



#pragma mark - Protocol: APPSContentLoading

- (APPSLoadableContentStateMachine *)stateMachine
{
	if (_stateMachine)
		return _stateMachine;
	
	_stateMachine = [[APPSLoadableContentStateMachine alloc] init];
	_stateMachine.delegate = self;
	return _stateMachine;
}


- (NSString *)loadingState
{
	// Don't cause the creation of the state machine just by inspection of the loading state.
	if (!_stateMachine)
		return APPSLoadStateInitial;
	return _stateMachine.currentState;
}


- (void)setLoadingState:(NSString *)loadingState
{
	APPSLoadableContentStateMachine *stateMachine = self.stateMachine;
	if (loadingState != stateMachine.currentState)
		stateMachine.currentState = loadingState;
}


- (void)endLoadingContentWithState:(NSString *)state error:(NSError *)error update:(dispatch_block_t)update
{
	self.loadingError = error;
	self.loadingState = state;
	
    dispatch_block_t pendingUpdates = _pendingUpdateBlock;
    _pendingUpdateBlock = nil;
    
    [self performUpdate:^{
        if (pendingUpdates)
            pendingUpdates();
        if (update)
            update();
    }];
    
    [self notifyContentLoadedWithError:error];
}


- (void)setNeedsLoadContent
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadContent) object:nil];
	[self performSelector:@selector(loadContent) withObject:nil afterDelay:0];
}


- (void)resetContent
{
    _resettingContent = YES;
    // This ONLY works because the resettingContent flag is set to YES. This will be checked in -missingTransitionFromState:toState: to decide whether to allow the transition.
    self.loadingState = APPSLoadStateInitial;
    _resettingContent = NO;
    
    // Content has been reset, if we're loading something, chances are we don't need it.
    self.loadingProgress.cancelled = YES;
}


- (void)loadContent
{
    NSString *loadingState = self.loadingState;
    self.loadingState = (([loadingState isEqualToString:APPSLoadStateInitial] || [loadingState isEqualToString:APPSLoadStateLoadingContent]) ? APPSLoadStateLoadingContent : APPSLoadStateRefreshingContent);
    
    [self notifyWillLoadContent];
    
    __weak typeof(&*self) weakself = self;
    
    APPSLoadingProgress *loadingProgress = [APPSLoadingProgress loadingProgressWithCompletionHandler:^(NSString *newState, NSError *error, APPSLoadingUpdateBlock update){
        // The only time newState will be nil is if the progress was cancelled.
        if (!newState)
            return;
        
        [self endLoadingContentWithState:newState error:error update:^{
            APPSDataSource *me = weakself;
            if (update && me)
                update(me);
        }];
    }];
    
    // Tell previous loading instance it's no longer current and remember this loading instance
    self.loadingProgress.cancelled = YES;
    self.loadingProgress = loadingProgress;
    
    [self beginLoadingContentWithProgress:loadingProgress];
}


- (void)beginLoadingContentWithProgress:(APPSLoadingProgress *)progress
{
    [self loadContentWithProgress:progress];
}


- (void)loadContentWithProgress:(APPSLoadingProgress *)progress
{
    // This default implementation just signals that the load completed.
    [progress done];
}


- (void)whenLoaded:(dispatch_block_t)block
{
    __block atomic_bool complete;
    atomic_init(&complete, false);
    
    dispatch_block_t oldLoadingCompleteBlock = self.loadingCompletionBlock;
    
    self.loadingCompletionBlock = ^{
        // Already called the completion handler
        bool expected = false;
        if  (!atomic_compare_exchange_strong(&complete, &expected, true)) {
            return;
        }
        
        // Call the previous completion block if there was one.
        if (oldLoadingCompleteBlock)
            oldLoadingCompleteBlock();
        
        block();
    };
}


- (void)stateWillChange
{
	// loadingState property isn't really Key Value Compliant, so let's begin a change notification
	[self willChangeValueForKey:@"loadingState"];
}


- (void)stateDidChange
{
	// loadingState property isn't really Key Value Compliant, so let's finish a change notification
	[self didChangeValueForKey:@"loadingState"];
}


- (void)didEnterLoadingState
{
    [self presentActivityIndicatorForSections:nil];
}


- (void)didExitLoadingState
{
    [self dismissPlaceholderForSections:nil];
}


- (void)didEnterNoContentState
{
    if (self.noContentPlaceholder)
        [self presentPlaceholder:self.noContentPlaceholder forSections:nil];
}


- (void)didEnterErrorState
{
    if (self.errorPlaceholder)
        [self presentPlaceholder:self.errorPlaceholder forSections:nil];
}


- (void)didExitErrorState
{
    if (self.errorPlaceholder)
        [self dismissPlaceholderForSections:nil];
}


- (void)didExitNoContentState
{
    if (self.noContentPlaceholder)
        [self dismissPlaceholderForSections:nil];
}


- (NSString *)missingTransitionFromState:(NSString *)fromState toState:(NSString *)toState
{
    if (!_resettingContent)
        return nil;
    
    if ([APPSLoadStateInitial isEqualToString:toState])
        return toState;
    
    // All other cases fail
    return nil;
}



#pragma mark - Placeholder

- (BOOL)shouldShowActivityIndicator
{
    NSString *loadingState = self.loadingState;
    
    return (self.showsActivityIndicatorWhileRefreshingContent && [loadingState isEqualToString:APPSLoadStateRefreshingContent]) || [loadingState isEqualToString:APPSLoadStateLoadingContent];
}

- (BOOL)shouldShowPlaceholder
{
    return self.placeholder ? YES : NO;
}

- (void)presentActivityIndicatorForSections:(NSIndexSet *)sections
{
    id<APPSDataSourceDelegate> delegate = self.delegate;
    if (![delegate respondsToSelector:@selector(dataSource:didPresentActivityIndicatorForSections:)])
        return;
    
    if (!sections)
        sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.numberOfSections)];
    
    [self internalPerformUpdate:^{
        if ([sections containsIndexesInRange:NSMakeRange(0, self.numberOfSections)])
            self.placeholder = [APPSDataSourcePlaceholder placeholderWithActivityIndicator];
        
        // The data source can't do this itself, so the request is passed up the tree. Ultimately this will be handled by the collection view by passing it along to the layout.
        [delegate dataSource:self didPresentActivityIndicatorForSections:sections];
    }];
}

- (void)presentPlaceholder:(APPSDataSourcePlaceholder *)placeholder forSections:(NSIndexSet *)sections
{
    id<APPSDataSourceDelegate> delegate = self.delegate;
    if (![delegate respondsToSelector:@selector(dataSource:didPresentPlaceholderForSections:)])
        return;
    
    if (!sections)
        sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.numberOfSections)];
    
    [self internalPerformUpdate:^{
        if (placeholder && [sections containsIndexesInRange:NSMakeRange(0, self.numberOfSections)])
            self.placeholder = placeholder;
        
        // The data source can't do this itself, so the request is passed up the tree. Ultimately this will be handled by the collection view by passing it along to the layout.
        [delegate dataSource:self didPresentPlaceholderForSections:sections];
    }];
}

- (void)dismissPlaceholderForSections:(NSIndexSet *)sections
{
    id<APPSDataSourceDelegate> delegate = self.delegate;
    if (![delegate respondsToSelector:@selector(dataSource:didDismissPlaceholderForSections:)])
        return;
    
    if (!sections)
        sections = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.numberOfSections)];
    
    [self internalPerformUpdate:^{
        // Clear the placeholder when the sections represents the entire range of sections in this data source.
        if ([sections containsIndexesInRange:NSMakeRange(0, self.numberOfSections)])
            self.placeholder = nil;
        
        // We need to pass this up the tree of data sources until it reaches the collection view, which will then pass it to the layout.
        [delegate dataSource:self didDismissPlaceholderForSections:sections];
    }];
}

- (void)updatePlaceholderView:(APPSTablePlaceholderView *)placeholderView forSectionAtIndex:(NSInteger)sectionIndex
{
    NSString *message;
    NSString *title;
    UIImage *image;
    
    if (!placeholderView)
        return;
    
    // Handle loading and refreshing states
    if (self.shouldShowActivityIndicator) {
        [placeholderView showActivityIndicator:YES];
        [placeholderView hidePlaceholderAnimated:YES];
        return;
    }
    
    // For other states, start by turning off the activity indicator
    [placeholderView showActivityIndicator:NO];
    
    APPSDataSourcePlaceholder *placeholder = self.placeholder;
    title = placeholder.title;
    message = placeholder.message;
    image = placeholder.image;
    
    if (title || message || image)
        [placeholderView showPlaceholderWithTitle:title message:message image:image animated:YES];
    else
        [placeholderView hidePlaceholderAnimated:YES];
}



- (APPSTablePlaceholderView *)dequeuePlaceholderViewForTableView:(UITableView *)tableView
{
    APPSTablePlaceholderView *placeholderView = (APPSTablePlaceholderView*)[tableView viewWithTag:APPSDataSourcePlaceholderTag];
    if (!placeholderView) {
        placeholderView = [[APPSTablePlaceholderView alloc] initWithFrame:tableView.bounds];
        placeholderView.tag = APPSDataSourcePlaceholderTag;
        placeholderView.userInteractionEnabled = NO;
        placeholderView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [tableView addSubview:placeholderView];
    }
    return placeholderView;
}


#pragma mark - Notification methods

- (void)didBecomeActive
{
    NSString *loadingState = self.loadingState;
    
    if ([loadingState isEqualToString:APPSLoadStateInitial]) {
        [self setNeedsLoadContent];
        return;
    }
    
    if (self.shouldShowActivityIndicator) {
        [self presentActivityIndicatorForSections:nil];
        return;
    }
    
    // If there's a placeholder, we assume it needs to be re-presented. This means the placeholder ivar must be cleared when the placeholder is dismissed.
    if (self.placeholder)
        [self presentPlaceholder:self.placeholder forSections:nil];
}

- (void)willResignActive
{
    // We need to hang onto the placeholder, because dismiss clears it
    APPSDataSourcePlaceholder *placeholder = self.placeholder;
    if (placeholder) {
        [self dismissPlaceholderForSections:nil];
        self.placeholder = placeholder;
    }
}

#if DEBUG
BOOL APPSInDataSourceUpdate(APPSDataSource *dataSource)
{
    // We don't care if there's no delegate.
    if (!dataSource.delegate)
        return YES;
    
    dispatch_queue_t main_queue = dispatch_get_main_queue();
    
    void *markerValue = dispatch_queue_get_specific(main_queue, APPSPerformUpdateQueueSpecificKey);
    return markerValue != nil;
}
#endif

- (void)performUpdate:(dispatch_block_t)update
{
    [self performUpdate:update complete:nil];
}

- (void)performUpdate:(dispatch_block_t)block complete:(dispatch_block_t)completionHandler
{
    APPS_ASSERT_MAIN_THREAD;
    
    // If this data source is loading, wait until we're done before we execute the update
    if ([self.loadingState isEqualToString:APPSLoadStateLoadingContent]) {
        __weak typeof(&*self) weakself = self;
        [self enqueueUpdateBlock:^{
            [weakself performUpdate:block complete:completionHandler];
        }];
        return;
    }
    
    [self internalPerformUpdate:block complete:completionHandler];
}

- (void)internalPerformUpdate:(dispatch_block_t)block
{
    [self internalPerformUpdate:block complete:nil];
}

- (void)internalPerformUpdate:(dispatch_block_t)block complete:(dispatch_block_t)completionHandler
{
#if DEBUG
    dispatch_block_t updateBlock = ^{
        dispatch_queue_t main_queue = dispatch_get_main_queue();
        
        // Establish a marker that we're in an update block. This will be used by the APPS_ASSERT_IN_DATASOURCE_UPDATE to ensure things will update correctly.
        void *originalValue = dispatch_queue_get_specific(main_queue, APPSPerformUpdateQueueSpecificKey);
        if (!originalValue)
            dispatch_queue_set_specific(main_queue, APPSPerformUpdateQueueSpecificKey, (__bridge void *)(self), NULL);
        
        if (block)
            block();
        
        if (!originalValue)
            dispatch_queue_set_specific(main_queue, APPSPerformUpdateQueueSpecificKey, originalValue, NULL);
    };
#else
    dispatch_block_t updateBlock = block;
#endif
    
    // If our delegate our delegate can handle this for us, pass it up the tree
    id<APPSDataSourceDelegate> delegate = self.delegate;
    if (delegate && [delegate respondsToSelector:@selector(dataSource:performBatchUpdate:complete:)])
        [delegate dataSource:self performBatchUpdate:updateBlock complete:completionHandler];
    else {
        if (updateBlock)
            updateBlock();
        if (completionHandler)
            completionHandler();
    }
}


- (void)enqueueUpdateBlock:(dispatch_block_t)block
{
    dispatch_block_t update;
    
    if (_pendingUpdateBlock) {
        dispatch_block_t oldPendingUpdate = _pendingUpdateBlock;
        update = ^{
            oldPendingUpdate();
            block();
        };
    }
    else
        update = block;
    
    self.pendingUpdateBlock = update;
}


- (void)notifyItemsInsertedAtIndexPaths:(NSArray *)insertedIndexPaths
{
    APPS_ASSERT_MAIN_THREAD;
    id<APPSDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didInsertItemsAtIndexPaths:)]) {
        [delegate dataSource:self didInsertItemsAtIndexPaths:insertedIndexPaths];
    }
}


- (void)notifyItemsRemovedAtIndexPaths:(NSArray *)removedIndexPaths
{
    id<APPSDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didRemoveItemsAtIndexPaths:)]) {
        [delegate dataSource:self didRemoveItemsAtIndexPaths:removedIndexPaths];
    }
}


- (void)notifyItemsRefreshedAtIndexPaths:(NSArray *)refreshedIndexPaths
{
    APPS_ASSERT_MAIN_THREAD;
    id<APPSDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didRefreshItemsAtIndexPaths:)]) {
        [delegate dataSource:self didRefreshItemsAtIndexPaths:refreshedIndexPaths];
    }
}


- (void)notifyItemMovedFromIndexPath:(NSIndexPath *)indexPath toIndexPaths:(NSIndexPath *)newIndexPath
{
    APPS_ASSERT_MAIN_THREAD;
    id<APPSDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didMoveItemAtIndexPath:toIndexPath:)]) {
        [delegate dataSource:self didMoveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
    }
}


- (void)notifySectionsInserted:(NSIndexSet *)sections
{
	APPS_ASSERT_MAIN_THREAD;
	
	id<APPSDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didInsertSections:)]) {
		[delegate dataSource:self didInsertSections:sections];
	}
}


- (void)notifySectionsRemoved:(NSIndexSet *)sections
{
	APPS_ASSERT_MAIN_THREAD;
	
	id<APPSDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didRemoveSections:)]) {
		[delegate dataSource:self didRemoveSections:sections];
	}
}


- (void)notifySectionsRefreshed:(NSIndexSet *)sections
{
	APPS_ASSERT_MAIN_THREAD;
	
	id<APPSDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didRefreshSections:)]) {
		[delegate dataSource:self didRefreshSections:sections];
	}
}

- (void)notifySectionMovedFrom:(NSInteger)section to:(NSInteger)newSection
{
	APPS_ASSERT_MAIN_THREAD;
	
	id<APPSDataSourceDelegate> delegate = self.delegate;
	if ([delegate respondsToSelector:@selector(dataSource:didMoveSection:toSection:)]) {
		[delegate dataSource:self didMoveSection:section toSection:newSection];
	}
}


- (void)notifyDidReloadData
{
    APPS_ASSERT_MAIN_THREAD;
    
    id<APPSDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSourceDidReloadData:)]) {
        [delegate dataSourceDidReloadData:self];
    }
}


- (void)notifyContentLoadedWithError:(NSError *)error
{
    APPS_ASSERT_MAIN_THREAD;
    
    dispatch_block_t loadingCompleteBlock = self.loadingCompletionBlock;
    self.loadingCompletionBlock = nil;
    if (loadingCompleteBlock)
        loadingCompleteBlock();
    
    id<APPSDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSource:didLoadContentWithError:)]) {
        [delegate dataSource:self didLoadContentWithError:error];
    }
}

- (void)notifyWillLoadContent
{
    APPS_ASSERT_MAIN_THREAD;
    
    id<APPSDataSourceDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(dataSourceWillLoadContent:)]) {
        [delegate dataSourceWillLoadContent:self];
    }
}



#pragma mark - Protocol: UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.numberOfSections;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // When we're showing a placeholder, we have to lie to the table view about the number of items we have. Otherwise, it will ask for layout attributes that we don't have.
    return self.placeholder ? 0 : [self numberOfRowsInSection:section];
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(NO, @"Should be implemented by subclasses");
    return nil;
}



#pragma mark - Debugging Support

- (NSString *)debugDescription;
{
    // Print the class name and memory address, per: http://stackoverflow.com/a/7555194/535054
    NSMutableString *message = [NSMutableString stringWithFormat:@"<%@: %p> ; data: {\n\t", [[self class] description], (__bridge void *)self];
    [message appendFormat:@"title: %@\n\t", self.title];
    
    [message appendString:@"}\n"];
    
    return message;
}

@end
