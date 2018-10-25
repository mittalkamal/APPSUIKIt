//
//  APPSContentLoading.m
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
 APPSLoadableContentStateMachine — This is the state machine that manages transitions for all loadable content.
 APPSLoading — This is a signalling object used to simplify transitions on the statemachine and provide update blocks.
 APPSContentLoading — A protocol adopted by the APPSDataSource class for loading content.
 */

#import "APPSContentLoading.h"
#import <libkern/OSAtomic.h>

#undef DEBUG
#define DEBUG_APPSLOADING 0

NSString * const APPSLoadStateInitial = @"Initial";
NSString * const APPSLoadStateLoadingContent = @"LoadingState";
NSString * const APPSLoadStateRefreshingContent = @"RefreshingState";
NSString * const APPSLoadStateContentLoaded = @"LoadedState";
NSString * const APPSLoadStateNoContent = @"NoContentState";
NSString * const APPSLoadStateError = @"ErrorState";


@implementation APPSLoadableContentStateMachine


#pragma mark - Instantiation

- (instancetype)init
{
    self = [super init];
    if (!self)
        return nil;

	self.validTransitions = @{
							  APPSLoadStateInitial : @[APPSLoadStateLoadingContent],
							  APPSLoadStateLoadingContent : @[APPSLoadStateContentLoaded, APPSLoadStateNoContent, APPSLoadStateError],
							  APPSLoadStateRefreshingContent : @[APPSLoadStateContentLoaded, APPSLoadStateNoContent, APPSLoadStateError],
							  APPSLoadStateContentLoaded : @[APPSLoadStateRefreshingContent, APPSLoadStateNoContent, APPSLoadStateError],
							  APPSLoadStateNoContent : @[APPSLoadStateRefreshingContent, APPSLoadStateContentLoaded, APPSLoadStateError],
							  APPSLoadStateError : @[APPSLoadStateLoadingContent, APPSLoadStateRefreshingContent, APPSLoadStateNoContent, APPSLoadStateContentLoaded]
							  };
    self.currentState = APPSLoadStateInitial;
	return self;
}

@end



@interface APPSLoadingProgress()
@property (nonatomic, readwrite, getter = isCancelled) BOOL cancelled;
@property (nonatomic, copy) void (^block)(NSString *newState, NSError *error, APPSLoadingUpdateBlock update);
@end

@implementation APPSLoadingProgress


#if DEBUG
{
	int32_t _complete;
}
#endif



#pragma mark - Instantiation

+ (instancetype)loadingProgressWithCompletionHandler:(void(^)(NSString *state, NSError *error, APPSLoadingUpdateBlock update))handler
{
    NSParameterAssert(handler != nil);
    APPSLoadingProgress *loading = [[self alloc] init];
    loading.block = handler;
    loading.cancelled = NO;
    return loading;
}


#if DEBUG
- (void)appsLoadingDebugDealloc
{
	if (OSAtomicCompareAndSwap32(0, 1, &_complete))
#if DEBUG_APPSLOADING
		NSAssert(false, @"No completion methods called on APPSLoading instance before dealloc called.");
#else
	NSLog(@"No completion methods called on APPSLoadingProgress instance before dealloc called. Break in -[APPSLoadingProgress appsLoadingDebugDealloc] to debug this.");
#endif
}


- (void)dealloc
{
	// make this easier to debug by having a separate method for a breakpoint.
	[self appsLoadingDebugDealloc];
}
#endif



#pragma mark - Public Interface

- (void)doneWithNewState:(NSString *)newState error:(NSError *)error update:(APPSLoadingUpdateBlock)update
{
#if DEBUG
	if (!OSAtomicCompareAndSwap32(0, 1, &_complete))
		NSAssert(false, @"completion method called more than once");
#endif
	
	void (^block)(NSString *state, NSError *error, APPSLoadingUpdateBlock update) = _block;
	
    if (block) {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(newState, error, update);
        });
        
        _block = nil;
    }
	
}


- (void)setCancelled:(BOOL)cancelled
{
    _cancelled = cancelled;
    // When cancelled, we immediately ignore the result of this loading operation. If one of the completion methods is called in DEBUG mode, we'll get an assertion.
    if (cancelled)
        [self ignore];
}


- (void)ignore
{
	[self doneWithNewState:nil error:nil update:nil];
}


- (void)done
{
	[self doneWithNewState:APPSLoadStateContentLoaded error:nil update:nil];
}


- (void)updateWithContent:(APPSLoadingUpdateBlock)update
{
	[self doneWithNewState:APPSLoadStateContentLoaded error:nil update:update];
}


- (void)doneWithError:(NSError *)error
{
	NSString *newState = error ? APPSLoadStateError : APPSLoadStateContentLoaded;
	[self doneWithNewState:newState error:error update:nil];
}


- (void)updateWithNoContent:(APPSLoadingUpdateBlock)update
{
	[self doneWithNewState:APPSLoadStateNoContent error:nil update:update];
}
@end

