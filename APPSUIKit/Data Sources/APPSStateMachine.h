//
//  APPSStateMachine.h
//
//  Created by Ken Grigsby on 8/24/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A general purpose state machine implementation. The state machine will call methods on the delegate based on the name of the state. For example, when transitioning from StateA to StateB, the state machine will first call -shouldEnterStateA. If that method isn't implemented or returns YES, the state machine updates the current state. It then calls -didExitStateA followed by -didEnterStateB. Finally, if implemented, it will call -stateDidChange.
 Assumptions:
 - The number of states and transitions are relatively few
 - State transitions are relatively infrequent
 - Multithreadsafety/atomicity is handled at a higher level
 */

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@protocol APPSStateMachineDelegate <NSObject>

@optional

// Completely generic state change hook
- (void)stateWillChange;
- (void)stateDidChange;

/// Return the new state or nil for no change for an missing transition from a state to another state. If implemented, overrides the base implementation completely.
- (NSString *)missingTransitionFromState:(NSString *)fromState toState:(NSString *)toState;

@end

/**
 A generic state machine implementation representing states as simple strings. It is usually not necessary to subclass AAPLStateMachine. Instead, set the delegate property and implement state transition methods as appropriate.
 
 The state machine will call methods on the delegate based on the name of the state. For example, when transitioning from StateA to StateB, the state machine will first call `-shouldEnterStateA`. If that method isn't implemented or returns YES, the state machine updates the current state. It then calls `-didExitStateA` followed by `-didEnterStateB`. Finally, if implemented, it will call `-stateDidChange`.
 
 Assumptions:
 
 - The number of states and transitions are relatively few
 - State transitions are relatively infrequent
 - Multithreadsafety/atomicity is handled at a higher level
 */
@interface APPSStateMachine : NSObject

/// Initialize a state machine with the initial state and valid transitions.
- (instancetype)init NS_DESIGNATED_INITIALIZER;

/// The current state of the state machine. This will only be nil after the state machine is created and before the state is set. It is not valid to set this back to nil.
@property (nullable, copy, atomic) NSString *currentState;

/**
 Definition of the valid transitions for this state machine. This is a dictionary where the keys are the state names and the value for each key is an array of the valid next state. For example:
 
 doorStateMachine.validTransitions = @{
 @"Locked" : @[@"Closed"],
 @"Closed" : @[@"Open", @"Locked"],
 @"Open" : @[@"Closed"]
 };
 
 */
@property (copy, atomic) NSDictionary *validTransitions;

/// If set, APPSStateMachine invokes transition methods on this delegate instead of self. This allows APPSStateMachine to be used where subclassing doesn't make sense. The delegate is invoked on the same thread as -setCurrentState:
@property (nullable, weak, atomic) id<APPSStateMachineDelegate> delegate;

/// use NSLog to output state transitions; useful for debugging, but can be noisy
@property (assign, nonatomic) BOOL shouldLogStateTransitions;

/// set current state and return YES if the state changed successfully to the supplied state, NO otherwise. Note that this does _not_ bypass missingTransitionFromState, so, if you invoke this, you must also supply an missingTransitionFromState implementation that avoids raising exceptions.
- (BOOL)applyState:(NSString *)state;

/// For subclasses. Base implementation raises IllegalStateTransition exception. Need not invoke super unless desired. Should return the desired state if it doesn't raise, or nil for no change.
- (NSString *)missingTransitionFromState:(NSString *)fromState toState:(NSString *)toState;

@end



NS_ASSUME_NONNULL_END
