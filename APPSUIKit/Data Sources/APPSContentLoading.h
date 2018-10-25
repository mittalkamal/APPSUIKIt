//
//  APPSContentLoading.h
//
//  Created by Ken Grigsby on 8/24/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//
// This code was taken from the WWDC 2015 Sample Code for Session AdvancedCollectionView: Advanced User Interfaces Using Collection View
// https://developer.apple.com/sample-code/wwdc/2015/?q=advanced%20user%20interfaces.

@import Foundation;

#import "APPSStateMachine.h"

/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 AAPLLoadableContentStateMachine — This is the state machine that manages transitions for all loadable content.
 AAPLLoading — This is a signalling object used to simplify transitions on the statemachine and provide update blocks.
 AAPLContentLoading — A protocol adopted by the AAPLDataSource class for loading content.
 */

NS_ASSUME_NONNULL_BEGIN




/// The initial state.
extern NSString *const APPSLoadStateInitial;

/// The first load of content.
extern NSString *const APPSLoadStateLoadingContent;

/// Subsequent loads after the first.
extern NSString *const APPSLoadStateRefreshingContent;

/// After content is loaded successfully.
extern NSString *const APPSLoadStateContentLoaded;

/// No content is available.
extern NSString *const APPSLoadStateNoContent;

/// An error occurred while loading content.
extern NSString *const APPSLoadStateError;




/// A block that performs updates on the object that is loading. The object parameter is the receiver of the `-loadContentWithProgress:` message.
typedef void (^APPSLoadingUpdateBlock)(id object);




/** A specialization of APPSStateMachine for content loading.
 
 The valid transitions for APPSLoadableContentStateMachine are the following:
 
 - APPSLoadStateInitial → APPSLoadStateLoadingContent
 - APPSLoadStateLoadingContent → APPSLoadStateContentLoaded, APPSLoadStateNoContent, or APPSLoadStateError
 - APPSLoadStateRefreshingContent → APPSLoadStateContentLoaded, APPSLoadStateNoContent, or APPSLoadStateError
 - APPSLoadStateContentLoaded → APPSLoadStateRefreshingContent, APPSLoadStateNoContent, or APPSLoadStateError
 - APPSLoadStateNoContent → APPSLoadStateRefreshingContent, APPSLoadStateContentLoaded or APPSLoadStateError
 - APPSLoadStateError → APPSLoadStateLoadingContent, APPSLoadStateRefreshingContent, APPSLoadStateNoContent, or APPSLoadStateContentLoaded
 
 The primary difference between `APPSLoadStateLoadingContent` and `APPSLoadStateRefreshingContent` is whether or not the owner had content to begin with. Refreshing content implies there was content already loaded and it just needed to be refreshed. This might require a different presentation (no loading indicator for example) than loading content for the first time.
 */
@interface APPSLoadableContentStateMachine : APPSStateMachine
@end



/** A class passed to the `-loadContentWithProgress:` method of an object adopting the `AAPLContentLoading` protocol.
 
 Implementers of `-loadContentWithProgress:` can use this object to signal the success or failure of the loading operation as well as the next state for their data source.
 */
@interface APPSLoadingProgress : NSObject

/// Signals that this result should be ignored. Sends a nil value for the state to the completion handler.
- (void)ignore;

/// Signals that loading is complete with no errors. This triggers a transition to the Loaded state.
- (void)done;

/// Signals that loading failed with an error. This triggers a transition to the Error state.
- (void)doneWithError:(NSError *)error;

/// Signals that loading is complete, transitions into the Loaded state and then runs the update block.
- (void)updateWithContent:(APPSLoadingUpdateBlock)update;

/// Signals that loading completed with no content, transitions to the No Content state and then runs the update block.
- (void)updateWithNoContent:(APPSLoadingUpdateBlock)update;

/// Has this loading operation been cancelled? It's important to check whether the loading progress has been cancelled before calling one of the completion methods (-ignore, -done, -doneWithError:, updateWithContent:, or -updateWithNoContent:). When loading has been cancelled, updating via a completion method will throw an assertion in DEBUG mode.
@property (nonatomic, readonly, getter = isCancelled) BOOL cancelled;

/// create a new loading helper
+ (instancetype)loadingProgressWithCompletionHandler:(void(^)( NSString * __nullable state,  NSError * __nullable error, __nullable APPSLoadingUpdateBlock update))handler;

@end




/// A protocol that defines content loading behavior
@protocol APPSContentLoading <NSObject>
/// The current state of the content loading operation
@property (nonatomic, copy) NSString *loadingState;
/// Any error that occurred during content loading. Valid only when loadingState == APPSLoadStateError.
@property (nonatomic, strong) NSError *loadingError;

/// Public method used to begin loading the content.
- (void)loadContentWithProgress:(APPSLoadingProgress *)progress;
/// Public method used to reset the content of the receiver.
- (void)resetContent;

@end




NS_ASSUME_NONNULL_END
