//
//  APPSContainerViewController.h
//  Appstronomy UIKit
//
//  Created by Sohail Ahmed on 5/9/13.
//  Copyright (c) 2013 Appstronomy. All rights reserved.
//

#import "APPSTaggedNaming.h"
#import "APPSBaseViewController.h"

#pragma mark - Container Controller

// Transition Type
typedef NS_ENUM(NSUInteger, APPSContainerControllerTransitionType) {
    APPSContainerControllerTransitionType_None = 0,
    APPSContainerControllerTransitionType_Push,
    APPSContainerControllerTransitionType_Cover,
    APPSContainerControllerTransitionType_Reveal,
    APPSContainerControllerTransitionType_Modal
};

// Transition Direction
typedef NS_ENUM(NSUInteger, APPSContainerControllerTransitionDirection) {
    APPSContainerControllerTransitionDirection_None = 0,
    APPSContainerControllerTransitionDirection_Left,
    APPSContainerControllerTransitionDirection_Right,
    APPSContainerControllerTransitionDirection_Up,
    APPSContainerControllerTransitionDirection_Down
};



@class APPSContainerViewController;

/**
 Provides the ability for any UIViewController to access its closest container controller, if one exists
 in its ancestor chain that is a member of the 'APPSContainerViewController' class.
 */
@interface UIViewController (APPSContainerViewController)

/**
 Returns the nearest ancestor container controller that is of kind @c APPSContainerViewController.
 */
@property (readonly, nonatomic) APPSContainerViewController *apps_containerController;

/**
 Returns the top-most ancestor container controller that is of kind @c APPSContainerViewController.
 */
@property (readonly, nonatomic) APPSContainerViewController *apps_topContainerController;

@end


/**
 This view controller container class is meant to be sub-classed, so that a subclass can adjust the frame of the
 containerView, as well as provide additional high level behaviors that make calls to the child controller view
 transitions that we provide.
 
 Subclasses are encouraged to set self.containerView.clipsToBounds = NO. Although we have this on by default, it incurs
 a performance penalty. If your container controller subclass takes up the majority of the view and/or the transitions
 are limited to those that won't cause a spilling outside of the container view, then you don't need to keep the
 clipToBounds property enabled.
 
 So long as a controller is a child of ours, we the Container will hold a strong reference to it. We do this via the
 APPSViewControllerStackEntry instance stored in our infoStack.
 */
@interface APPSContainerViewController : APPSBaseViewController <APPSTaggedNaming>

#pragma read-only
@property(readonly, nonatomic) UIViewController *visibleViewController;
@property(readonly, nonatomic) UIViewController *viewControllerBelowVisibleViewController;

#pragma strong
@property(strong, nonatomic) UIView *containerView;
@property(strong, nonatomic) NSString *taggedName;


#pragma mark - Initialization

/**
 Sets up the provided view controller as our initially visible view controller. We defer the work of actually
 adding it as a child controller and placing its view in our container view, until after we know that
 our view has been loaded.
 
 @param rootViewController The controller for initial display when we are displayed. It won't be animated,
 it will just be visible in place when we become visible.
 
 @return A new instance of our class configured to show the provided rootViewController.
 */
- (id)initWithRootViewController:(UIViewController *)rootViewController;



#pragma mark - Inquiries

/**
 Finds, within our pool of child view controllers, the earliest one that is of the type specified
 (or of a subclass of that type).
 
 @param viewControllerClass The Objective-C class whom we are trying to find a match for amongst our
 child view controllers.

 @return The first matching child view controller we find, otherwise nil.
 */
- (UIViewController *)existingChildViewControllerOfClass:(Class)viewControllerClass;


/**
 Finds, within our pool of child view controllers, the earliest one that has the tagged name specified.
 
 @param taggedName The friendly name given to the view controller we seek.
 @return The first matching child view controller we find, otherwise nil.
 */
- (UIViewController *)existingChildViewControllerWithTaggedName:(NSString *)taggedName;


/**
 Logs the contents of what child view controllers we have in what order, and by what
 type of transition.
 
 @param note The text to prefix the log output with. Useful for 'before' and 'after' type debug logging.
 */
- (void)logContentsWithNote:(NSString *)note;



#pragma mark - Utilities

/**
 Determines the height of the status bar we should account for, based on whether the status bar is present or not.
 Because we determine this based on the status bar frame, we can handle the case of no status bar, of regular status bar
 and of double height status bar.
 */
- (CGFloat)statusBarHeight;


/**
 Takes a view controller and sets its frame to match our containerView's bounds. We also ensure
 that the incoming view controller has an auto resizing mask that gives it a flexible width and height.
 
 We do not actually add the incoming view controller as our child controller here. We merely prepare its view for
 insertion into our containerView.
 
 @param incomingViewController The new view controller to be displayed as a child view controller of ours.
 */
- (void)prepareIncomingChildViewController:(UIViewController *)incomingViewController;



#pragma mark - Child Management

/**
 Removes a child view controller (both view and controller) from our notion of it
 being a child we are responsible for. The change takes place immediately.
 
 This is an opportunity to possibly also free up resources for child view controllers not
 actively being used.
 
 @b NOTE: We use an 'apps_' prefix here because otherwise we have a conflict with an internal, inherited framework method.
 @b NOTE: Not yet tested.
 
 @param markedForRemovalViewController The view controller we will remove as a child of ours.
 */
- (void)apps_removeChildViewController:(UIViewController *)markedForRemovalViewController;


/**
 Removes all of our child view controllers except the one that is currently visible.
 Useful to trim down our resource footprint to just that which is immediately visible.
 */
- (void)removeAllChildrenExceptVisibleViewController;


/**
 Removes all child view controllers with the specified taggedName. Uses recursion to eliminate multiple
 matches (although having more than one child view controller instance in the Container with the same
 taggedName is bad form).
 
 @param taggedName The name to search for amongst our child view controllers.
 */
- (void)removeAllChildViewControllersWithTaggedName:(NSString *)taggedName;



#pragma mark - Transitions: Placements

/**
 Places the specified incoming view controller a view layer below the specified existing view controller.
 We also make sure the incoming view controller gets its appearance callbacks, even though it is a view layer below.
 
 The existing view controller must already be a child view controller of ours.
 
 We don't remove the existing view controller, and we'll add the incoming view controller as a child
 if we don't already have it as a child. If we do have it as a child, we're just re-arranging view layering.
 Note that this placement happens immediately when called, not over an animated duration.
 
 It may seem counter-intuitive, but even though we add the incoming view controller a layer below the
 existing view controller specified, we bracket the view manipulation with 'beginAppearanceTransition:animated:'
 and 'endAppearanceTransition' calls so that the incoming view controller will get its appearance callbacks. The
 presumption is that by being placed below an existing view controller without a formal transition from/to being called,
 a controlled animation of the higher layered view controller, is about to ensue.
 
 @param incomingViewController The view controller whose view will go beneath the other controller's.
 @param existingViewController The view controller that is already our child, under which, the incoming
    view controller's view will be placed.
 @param completion An optional completion block for execution after the placement is done.
 */
- (void)placeIncomingViewController:(UIViewController *)incomingViewController
     belowExistingViewController:(UIViewController *)existingViewController
                      completion:(void (^)(BOOL))completion;

/**
 Places the incoming view controller above the specified existing view controller.
 The existing view controller must already be a child view controller of ours.
 
 The existing view controller will get notified of the disappearance; the incoming
 view controller we explicitly notify of appearance if it was already our child
 (otherwise, the runtime handles the appearance callbacks to it).
 
 @param incomingViewController The view controller whose view will go above the other controller's.
 @param existingViewController The view controller that is already our child, above which, the incoming
 view controller's view will be placed.
 @param completion An optional completion block for execution after the placement is done.
 */
- (void)placeIncomingViewController:(UIViewController *)incomingViewController
     aboveExistingViewController:(UIViewController *)existingViewController
                      completion:(void (^)(BOOL))completion;

/**
 In this swap operation, we remove the existing view controller once the incoming view controller
 is installed as our child and its view is placed above the existing view controller.
 
 In this way, the removal of the existing view controller will not be visibly detected by the user.
 
 @b NOTE: Not yet tested.
 
 @param incomingViewController The view controller whose view will replace the other controller's.
 @param existingViewController The view controller that is already our child, but which will be discreetly removed.
 @param completion An optional completion block for execution after the swap is done.
 */
- (void)swapExistingViewController:(UIViewController *)existingViewController
        withIncomingViewController:(UIViewController *)incomingViewController
                        completion:(void (^)(BOOL))completion;


#pragma mark - Transitions: Push

/**
 This primitive handles push transitions, which means the from and to views are stitched together in the same plane.
 Only full transitions are supported (the incoming view controller must completely take over the view real estate
 that the from view controller occupied). There is no 'fall short' option.
 
 @param fromViewController The child view controller that will give way to the incoming 'toViewController'.
 Defaults to the currently visible view controller if not specified.
 @param toViewController The incoming view controller
 @param duration The time through which the transition animation takes place
 @param direction A canonical direction indicating left/right/top/bottom using the stated enumerated type
 @param options Standard bitwise OR of UIView animation options
 @param removeFromAsChild Whether to actually remove the fromViewController when the transition completes
 @param start An optional block; most useful for sound effects
 @param completion An optional block for after the transition completes
 */
- (void)pushWithTransitionFromViewController:(UIViewController *)fromViewController
                            toViewController:(UIViewController *)toViewController
                                    duration:(NSTimeInterval)duration
                                   direction:(APPSContainerControllerTransitionDirection)direction
                                     options:(UIViewAnimationOptions)options
                           removeFromAsChild:(BOOL)removeFromAsChild
                                       start:(void (^)(void))start
                                  completion:(void (^)(BOOL))completion;



#pragma mark - Transitions: Cover

/**
 This primitive handles cover transitions, which means the incoming view controller covers the from controller, as the
 former is animated into place. A partial cover transition is allowed.
 
 @param fromViewController The child view controller that will give way to the incoming 'toViewController'.
 Defaults to the currently visible view controller if not specified.
 @param toViewController The incoming view controller
 @param duration The time through which the transition animation takes place
 @param direction A canonical direction indicating left/right/top/bottom using the stated enumerated type
 @param options Standard bitwise OR of UIView animation options
 @param removeFromAsChild Whether to actually remove the fromViewController when the transition completes
 @param fallShortPoints How many points short of a full transition should we go. Use 0.0 to indicate a complete transition.
 @param start An optional block; most useful for sound effects
 @param completion An optional block for after the transition completes
 */
- (void)coverTransitionFromViewController:(UIViewController *)fromViewController
                         toViewController:(UIViewController *)toViewController
                                 duration:(NSTimeInterval)duration
                                direction:(APPSContainerControllerTransitionDirection)direction
                                  options:(UIViewAnimationOptions)options
                        removeFromAsChild:(BOOL)removeFromAsChild
                          fallShortPoints:(CGFloat)fallShortPoints
                                    start:(void (^)(void))start
                               completion:(void (^)(BOOL))completion;



#pragma mark - Transitions: Reveal

/**
 This primitive handles reveal transitions, which means the outgoing (from) view controller covers the
 incoming (to) view controller, as the former is animated out of view. The idea is that the 'to' view controller is
 revealed from underneath, as if it was always present and the 'from' view controller just needed to be slid out
 of place to reveal it.
 
 A partial reveal transition is allowed via the 'fallShortPoints' parameter.
 
 @param fromViewController The child view controller that will give way to the incoming 'toViewController'.
 Defaults to the currently visible view controller if not specified.
 @param toViewController The incoming view controller that isn't animated, but just gets revealed from underneath
 the 'from' controller.
 @param duration The time through which the transition animation (of the 'from' controller) takes place
 @param direction A canonical direction indicating left/right/top/bottom using the stated enumerated type
 @param options Standard bitwise OR of UIView animation options
 @param removeFromAsChild Whether to actually remove the fromViewController when the transition completes
 @param fallShortPoints How many points short of a full transition should we go. Use 0.0 to indicate a complete transition.
 @param start An optional block; most useful for sound effects
 @param completion An optional block for after the transition completes
 */
- (void)revealTransitionFromViewController:(UIViewController *)fromViewController
                         toViewController:(UIViewController *)toViewController
                                 duration:(NSTimeInterval)duration
                                direction:(APPSContainerControllerTransitionDirection)direction
                                  options:(UIViewAnimationOptions)options
                        removeFromAsChild:(BOOL)removeFromAsChild
                          fallShortPoints:(CGFloat)fallShortPoints
                                    start:(void (^)(void))start
                               completion:(void (^)(BOOL))completion;


#pragma mark - Transitions: Modal

/**
 Since we have our own Settings footer that we do NOT want the modal view controller to obscure, we'll animate in
 the modal view controller ourselves, so that we just clear the global footer.
 
 This method is opinionated - modal presentation means that the currently visible view controller is NOT removed
 as a child view controller of ours.
 
 @param modalViewController The new (incoming) child view controller to animate into place using a modal style.
 @param animated Whether to animate or not.
 @param completion Optional block to perform after the modal transition completes.
 */
- (void)presentModalViewController:(UIViewController *)modalViewController
                          animated:(BOOL)animated
                        completion:(void (^)(BOOL))completion;


/**
 Modally dismisses the currently visible child view controller, assuming it was modally displayed.
 
 @param animated Whether to animate or not.
 @param completion Optional block to perform after the modal dismissal transition completes.
 */
- (void)dismissModalViewControllerAnimated:(BOOL)animated
                                completion:(void (^)(BOOL))completion;

@end
