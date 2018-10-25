//
//  APPSContainerViewController.m
//  Appstronomy UIKit
//
//  Created by Sohail Ahmed on 5/9/13.
//  Copyright (c) 2013 Appstronomy. All rights reserved.
//

@import APPSFoundation;

#import "APPSContainerViewController.h"
#import "APPSViewControllerInfoStackEntry.h"
#import "APPSViewControllerInfoStack.h"
#import "UIView+Appstronomy.h"

@implementation UIViewController (APPSContainerViewController)

/**
 Provide a short-cut property to the closest ancestor container controller, if there is one.
 
 @return This view controller's closest containment controller ancestor.
 */
- (APPSContainerViewController *)apps_containerController
{
    UIViewController *iteratedAncestor = self.parentViewController;
    while (iteratedAncestor) {
        if ([iteratedAncestor isKindOfClass:[APPSContainerViewController class]]) {
            return (APPSContainerViewController *) iteratedAncestor;
        }
        
        iteratedAncestor = iteratedAncestor.parentViewController;
    }
    
    return nil; // No container controller found
}


/**
 Provides a short cut to get to the top most container controller in our ancestry, so we
 can have multiple levels of containment.
 
 @return The top most ancestral containment controller related to this view controller.
*/
- (APPSContainerViewController *)apps_topContainerController
{
    UIViewController *iteratedAncestor = self.apps_containerController;
    UIViewController *topmostContainerControllerFound = iteratedAncestor;

    while (iteratedAncestor) {
        if ([iteratedAncestor isKindOfClass:[APPSContainerViewController class]]) {
            topmostContainerControllerFound = iteratedAncestor;
        }

        iteratedAncestor = iteratedAncestor.parentViewController;
    }

    return (APPSContainerViewController *) topmostContainerControllerFound; // The highest view controller in the ancestry that is of our custom container type
}

@end



@interface APPSContainerViewController ()
/**
 Our record of active child controllers and their method of presentation:
 */
@property (strong, nonatomic) APPSViewControllerInfoStack *infoStack;
@end


@implementation APPSContainerViewController

#pragma mark - Initialization

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super init];
    
    if (self) {
        APPSAssert(rootViewController && [rootViewController isKindOfClass:[UIViewController class]],
        @"No rootViewController parameter passed to us of kind UIViewController, which is mandatory.");

        // Initialize the custom data structure that holds child view controllers with information about
        // the presentation transition type and direction:
        self.infoStack = [[APPSViewControllerInfoStack alloc] initWithContainmentController:self];
        [self.infoStack addEntryForController:rootViewController
                               transitionType:APPSContainerControllerTransitionType_None
                          transitionDirection:APPSContainerControllerTransitionDirection_None];
    }
    
    return self;
}



#pragma mark - View Lifecycle

/**
 Sets up our view, since we do not use a Nib for such. We color our main view blue and an interior inset content view,
 red. This is so that the two are easily distinguished.
 
 Of course, your subclass is meant to resize the content view and adjust the background colors of both. 
 */
- (void)loadView
{
    // Setup the base view that will eventually be our 'view' property for this class. We'll color it blue,
    // so that it is obvious that the view has not been covered / filled with content.
    CGRect frame = [[UIScreen mainScreen] bounds];
    UIView *baseView = [[UIView alloc] initWithFrame:frame];
    baseView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    baseView.backgroundColor = [UIColor blueColor];
    self.view = baseView;

    // Setup the content view, slightly inset from the base view. By making it red, it will be clear that
    // a child view controller is missing.
    frame = CGRectInset(frame, 40, 40);
    self.containerView = [[UIView alloc] initWithFrame:frame];
    self.containerView.backgroundColor = [UIColor blackColor]; //[UIColor redColor];
    self.containerView.clipsToBounds = YES; 
    
    // This auto resizing mask will allow the containerView to adjust to the orientation, by keeping the
    // margins constant and flexing its interior dimensions:
    self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // Finally, add the container view to our main view. Transitions managed by this container view controller
    // will all take place exclusively within the bounds of the container view.
    [self.view addSubview:self.containerView];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Currently, we don't have anything that happens at this stage.
}


/**
 We use this view lifecycle step to place the initial child view controller on screen if no child view controller
 reports being visible yet (as determined by the last added child view controller having us as its parent).
 
 If we find that this view controller doesn't have us as its parent, we'll add it formally as our child, and add its
 view into our container view.
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // The following are for debugging only:
    //self.containerView.layer.borderColor = [[UIColor greenColor] CGColor];
    //self.containerView.layer.borderWidth = 2.0;

    // Do we not have at least one view controller that is our child or marked to be added as our child?
    if (!self.visibleViewController) {
        // Affirmative: Nothing to do. Not a single view controller exists as yet for us to display
        return;
    }

    // Does the visible view controller already know it is our child?
    if (self.visibleViewController.parentViewController == self) {
        // Affirmative: Nothing to do as far as adding/removing.
        return;
    }

    // At this point, we must be in a situation where we've recently ourselves, been instantiated and given
    // a root view controller, that we now need to add as our first child view controller:
    [self installFirstChildViewController];
}



/**
 Dispose of any resources that can be recreated.
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // FUTURE: Consider jettisoning everything but the last two view controllers in order to free up memory.
}



#pragma mark - Configuration

/**
 This is where we're going to add the 'visible' view controller formally, as our child controller,
 and also add its view. We handle this one time, pre-transition initial placement of a child controller here.
*/
- (void)installFirstChildViewController
{
    // Adjust the contained view's frame to fit in our container:
    [self prepareIncomingChildViewController:self.visibleViewController];

    // The following are for debugging only:
    //self.visibleViewController.view.layer.borderColor = [[UIColor blueColor] CGColor];
    //self.visibleViewController.view.layer.borderWidth = 2.0;

    // Add the child controller; the subsequent 'willMoveToParentViewController' on the child view controller will
    // be called automatically as a result, per the documentation:
    // "When your custom container calls the addChildViewController: method, it automatically calls the
    // willMoveToParentViewController: method of the view controller to be added as a child before adding it."
    [self addChildViewController:self.visibleViewController];

    // Add the child view controller's view to our containerView:
    [self.containerView addSubview:self.visibleViewController.view];

    // Notify the child that the move is done (since this callback is not automatic):
    [self.visibleViewController didMoveToParentViewController:self];
}



#pragma mark - Inquiries

- (UIViewController *)existingChildViewControllerOfClass:(Class)viewControllerClass
{
    for (UIViewController *iteratedViewController in self.childViewControllers) {
        if ([iteratedViewController isKindOfClass:viewControllerClass]) {
            return iteratedViewController; // We found a match!
        }
    }

    return nil; // None found
}


- (UIViewController *)existingChildViewControllerWithTaggedName:(NSString *)taggedName;
{
    for (UIViewController *iteratedViewController in self.childViewControllers) {
        if ([iteratedViewController conformsToProtocol:@protocol(APPSTaggedNaming)]) {
            // Create local variable reference properly typed (for human readability!):
            id <APPSTaggedNaming> nameTaggedViewController = (id <APPSTaggedNaming>)iteratedViewController;
            
            // Does this view controller have the tagged name we seek?
            if ([nameTaggedViewController.taggedName isEqual:taggedName]) {
                // YES: We found a match!
                return iteratedViewController; 
            }
        }
    }

    return nil; // None found
}


/**
 Given that the child view controller to return to when our custom modal dismissal logic fires is not always the most
 recently visible child view controller, we have to find the most recently modally covered view controller.
 Fortunately, when presenting view controllers modally (with our custom method), we mark the covered up view controller
 (via its associated stack info entry), so that we know which child view controller to return to.
 */
- (UIViewController *)childViewControllerToReturnToForModalDismissal
{
    APPSViewControllerInfoStackEntry *entry = [self.infoStack closestModalDismissalReturnEntry];
    
    return entry.controller;
}


- (void)logContentsWithNote:(NSString *)note;
{
    [self.infoStack logContentsWithNote:note];
}



#pragma mark - Property Overrides

/**
 The concept of 'visible view controller' is driven by the last controller we've added as a child to our
 manually managed stack of view controllers. This is most easily retrieved from our info stack of child
 view controllers.
 
 @return The currently visible view controller.
*/
- (UIViewController *)visibleViewController
{
    return self.infoStack.visibleViewController;
}


/**
 Asks our child view controllers information stack for the previously visible child view controller.
 That is, the view controller one layer below the currently visible view controller.
 
 @return The previously visible view controller or nil if we have nothing below the currently visible view controller.
 */
- (UIViewController *)viewControllerBelowVisibleViewController
{
    return self.infoStack.viewControllerBelowVisibleViewController;
}



#pragma mark - Utilities

- (CGFloat)statusBarHeight
{
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}


/**
 We implement this iOS7 view controller method to tell the runtime to ask our 
 top most (i.e. visible) view controller for the status bar style it prefers.
 */
- (UIViewController *)childViewControllerForStatusBarStyle
{
    return self.visibleViewController;
}



#pragma mark - Utilities: Common

- (void)prepareIncomingChildViewController:(UIViewController *)incomingViewController
{
    // Adjust the incoming controller's view frame to fit in our container exactly:
    incomingViewController.view.frame = self.containerView.bounds;
    
    // Allow the incoming controller's view to fluidly expand/contract with that of our containerView:
    incomingViewController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}



/**
 Whether the transition type is a slide or cover (but not a reveal), we place the incoming view
 controller just off screen so that it can be animated into position. We handle the appropriate
 initial positioning based on the desired transition direction stated.
 
 @param toViewController The incoming view controller.
 @param direction The direction the incoming view controller will animate in. This informs where we set
    its starting position. For example, for an incoming (toViewController) that will animate in a leftward
    motion, we place its view to the right of our containerView.
*/
- (void)prepositionIncomingChildViewController:(UIViewController *)toViewController
                                     direction:(APPSContainerControllerTransitionDirection)direction;
{
    // Put the incoming controller just out of view. Position determined by desired direction:
    CGFloat originX = 0.0;
    CGFloat originY = 0.0;

    switch (direction) {
        case APPSContainerControllerTransitionDirection_Left:
            // Place the incoming view just off screen, to the right of the container view:
            originX = self.containerView.bounds.size.width;
            break;
        case APPSContainerControllerTransitionDirection_Right:
            // Place the incoming view just off screen, to the left of the container view:
            originX = -toViewController.view.bounds.size.width;
            break;
        case APPSContainerControllerTransitionDirection_Up:
            // Place the incoming view just off screen, to the bottom of the container view:
            originY = self.containerView.bounds.size.height;
            break;
        case APPSContainerControllerTransitionDirection_Down:
            // Place the incoming view just off screen, to the top of the container view:
            originY = -toViewController.view.bounds.size.height;
            break;

        default:
            break;
    }

    // Apply the determined origin adjustment from up above:
    [toViewController.view apps_setFrameOrigin:CGPointMake(originX, originY)];
}


/**
 We are the workhorse of animating in a new child view controller, and optionally animating and removing the previously
 current child view controller.
 
 When removing a 'from' view controller, we use the iOS container view controller method for transitioning
 from one view controller to another.
 
 When simply adding in a new 'to' view controller, we just animate the 'to' view controller in without disrupting
 the current child view controller's status with us, its parent.
 
 @param fromViewController The view controller we are transitioning from (typically, the currently visible one).
 @param toViewController The new, incoming view controller to be added as a child controller.
 @param duration The duration of the transition animation.
 @param options Bitwise OR of UIViewAnimationOptions.
 @param removeFromAsChild Whether to remove the 'from' view controller as a child of ours, once the transition completes.
 @param incomingAlreadyAChild Whether or not the incoming view controller is already a child of ours.
 @param animations A block of code representing properties to be animated.
 @param completion A block of code to run after the transition completes.
 */
- (void)processTransitionFromViewController:(UIViewController *)fromViewController
                           toViewController:(UIViewController *)toViewController
                                   duration:(NSTimeInterval)duration
                                    options:(UIViewAnimationOptions)options
                          removeFromAsChild:(BOOL)removeFromAsChild
                      incomingAlreadyAChild:(BOOL)incomingAlreadyAChild
                                 animations:(void (^)())animations
                                 completion:(void (^)(BOOL finished))completion;
{
    // Were we asked to remove the previously visible view controller after the transition?
    if (removeFromAsChild) {
        // YES: So we're going to transition from the currently visible controller to the new:
        [self transitionFromViewController:fromViewController
                          toViewController:toViewController
                                  duration:duration
                                   options:options
                                animations:animations
                                completion:^(BOOL finished) {
                                    if (!incomingAlreadyAChild) {
                                        [toViewController didMoveToParentViewController:self];
                                    }
                                    
                                    // Remove the 'from' view controller:
                                    [fromViewController removeFromParentViewController];
                                    [self.infoStack removeEntryForController:fromViewController];
                                    
                                    // Process completion block, if we were given one:
                                    if (completion) { completion(YES); }
                                }];
    }
    else {
        // NO: We're just going to animate in the new 'to' view controller without removing the 'from'.
        // Add the child view controller's view to our containerView, if it isn't already present. If
        // it was already present, we'd want it to stay however it already was (origin, layer, etc.).
        if (!incomingAlreadyAChild) {
            [self.containerView addSubview:toViewController.view];
        }

        // Do the the actual animation now:
        [UIView animateWithDuration:duration
                              delay:0.0
                            options:options
                         animations:animations
                         completion:^(BOOL finished) {
                             if (!incomingAlreadyAChild) {
                                [toViewController didMoveToParentViewController:self];
                             }

                             // Process completion block, if we were given one:
                             if (completion) { completion(YES); }
                         }];
    }
}



#pragma mark Utilities: Slide Transition

/**
 We call the appropriate helper methods that position from and to view controllers in their final positions,
 based on the direction specified for us. We only adjust the origin of the 'from' view controller.
 
 To achieve these changes with animation, this method should be called within a UIView animation block.
 
 @param fromViewController The controller we are transitioning from.
 @param toViewController The controller we are transitioning to.
 @param direction The direction the slide transition is meant to take.
*/
- (void)applyDestinationPositionsForSlideTransitionFromViewController:(UIViewController *)fromViewController
                                                     toViewController:(UIViewController *)toViewController
                                                            direction:(APPSContainerControllerTransitionDirection)direction;
{
    // The 'to' view controller will ultimately move to origin (0,0):
    [toViewController.view apps_setFrameOrigin:CGPointZero];

    switch (direction) {
        case APPSContainerControllerTransitionDirection_Left:
            // Slide Left
            [fromViewController.view apps_setFrameOriginX:-self.containerView.bounds.size.width];
            break;
        case APPSContainerControllerTransitionDirection_Right:
            // Slide Right:
            [fromViewController.view apps_setFrameOriginX:+self.containerView.bounds.size.width];
            break;
        case APPSContainerControllerTransitionDirection_Up:
            // Slide Up:
            [fromViewController.view apps_setFrameOriginY:-self.containerView.bounds.size.height];
            break;
        case APPSContainerControllerTransitionDirection_Down:
            // Slide Down:
            [fromViewController.view apps_setFrameOriginY:+self.containerView.bounds.size.height];
            break;

        default:
            break;
    }
}



#pragma mark Utilities: Cover Transition

/**
 We position the 'to' view controller in its final position, based on the direction specified for the transition that  
 will take place. The changes we make are only to the 'to' view controller's origin, so that the transition can be 
 animated.

 To achieve these changes with animation, this method should be called within a UIView animation block.
 
 @param toViewController The controller we are transitioning to.
 @param direction The direction the cover transition is meant to take. That is, the direction the incoming
    view controller will move as it covers the 'from' view controller.
 @param fallShortPoints How many points we should fall short of a full covering. For example, if you specified 80.0
    here, than the cover transition would almost complete, but fall short by 80 points of a full transition into place.
*/
- (void)applyDestinationPositionForCoverTransitionWithToViewController:(UIViewController *)toViewController
                                                             direction:(APPSContainerControllerTransitionDirection)direction
                                                       fallShortPoints:(CGFloat)fallShortPoints;
{
    // Are we instructed to completely cover the containerView?
    if (0 == fallShortPoints) {
        // YES. So the destination of the to-view-controller is an origin of (0,0).
        [toViewController.view apps_setFrameOrigin:CGPointZero];
        return;
    }

    // Checkpoint: We've been asked to do a cover transition that falls short by some amount.

    // Start with a destination of (0,0) and then adjust for the x or y axis in which we are meant to fall short.
    CGFloat originX = 0.0;
    CGFloat originY = 0.0;

    switch (direction) {
        case APPSContainerControllerTransitionDirection_Left:
            // Cover Left:
            originX += fallShortPoints;
            break;
        case APPSContainerControllerTransitionDirection_Right:
            // Cover Right:
            originX -= fallShortPoints;
            break;
        case APPSContainerControllerTransitionDirection_Up:
            // Cover Up:
            originY += fallShortPoints;
            break;
        case APPSContainerControllerTransitionDirection_Down:
            // Cover Down:
            originY -= fallShortPoints;
            break;

        default:
            break;
    }

    [toViewController.view apps_setFrameOrigin:CGPointMake(originX, originY)];
}



#pragma mark Utilities: Reveal Transition

/**
 We position the 'from' view controller in its final position, based on the direction specified for us.
 The changes we make are only to the from view controller's origin, so that the transition can be animated.
 
 To achieve these changes with animation, this method should be called within a UIView animation block.

 @param fromViewController The controller we are transitioning from.
 @param direction The direction the reveal transition is meant to take. The is, the direction the outgoing (from)
    view controller will move as it reveals the 'to' view controller below it.
 @param fallShortPoints How many points we should fall short of a full revealing. For example, if you specified 80.0
    here, than the reveal transition would almost complete, but fall short by 80 points of a full revelation.
 */
- (void)applyDestinationPositionForRevealTransitionWithFromViewController:(UIViewController *)fromViewController
                                                                direction:(APPSContainerControllerTransitionDirection)direction
                                                          fallShortPoints:(CGFloat)fallShortPoints;
{
    switch (direction) {
        case APPSContainerControllerTransitionDirection_Left:
            // Reveal Left:
            [fromViewController.view apps_setFrameOriginX:-self.containerView.bounds.size.width + fallShortPoints];
            break;
        case APPSContainerControllerTransitionDirection_Right:
            // Reveal Right:
            [fromViewController.view apps_setFrameOriginX:+self.containerView.bounds.size.width - fallShortPoints];
            break;
        case APPSContainerControllerTransitionDirection_Up:
            // Reveal Up:
            [fromViewController.view apps_setFrameOriginY:-self.containerView.bounds.size.height + fallShortPoints];
            break;
        case APPSContainerControllerTransitionDirection_Down:
            // Reveal Down:
            [fromViewController.view apps_setFrameOriginY:+self.containerView.bounds.size.height - fallShortPoints];
            break;

        default:
            break;
    }
}



#pragma mark - Child Management

- (void)apps_removeChildViewController:(UIViewController *)markedForRemovalViewController
{
    APPSAssert([self.childViewControllers containsObject:markedForRemovalViewController],
    @"The provided view controller '%@' is not already a child of this Container Controller, "
            "and it must be in order to use this method.", markedForRemovalViewController);

    // Prepare the existing view controller for removal:
    [markedForRemovalViewController willMoveToParentViewController:nil];

    // Update the info stack of our child view controllers:
    [self.infoStack removeEntryForController:markedForRemovalViewController];

    // Remove the view from our containerView:
    [markedForRemovalViewController.view removeFromSuperview];

    // Formally remove the existing controller from being our child:
    [markedForRemovalViewController removeFromParentViewController];
}


- (void)removeAllChildrenExceptVisibleViewController
{
    // Iterate through all of our child view controllers:
   for (UIViewController *iteratedChildViewController in self.childViewControllers) {
       // Is this iterated controller something other than the visible child controller?
       if (![iteratedChildViewController isEqual:self.visibleViewController]) {
           // YES: This is not the visible child controller, so get rid of it:
           [self apps_removeChildViewController:iteratedChildViewController];
       }
   }

   [self logContentsWithNote:@"Removed all child view controllers except the visible"];
}


- (void)removeAllChildViewControllersWithTaggedName:(NSString *)taggedName
{
    // Look for a matching child view controller (we'll get the first match back, even if there are multiple):
    UIViewController *matchingChildController = [self existingChildViewControllerWithTaggedName:taggedName];
    
    // Did we find one?
    if (matchingChildController) {
        // YES: Remove that view controller:
        [self apps_removeChildViewController:matchingChildController];
        
        // Recursively call ourselves in case there is another match we can remove:
        [self removeAllChildViewControllersWithTaggedName:taggedName];
    }
}



#pragma mark - Transitions: Placements

- (void)placeIncomingViewController:(UIViewController *)incomingViewController
        belowExistingViewController:(UIViewController *)existingViewController
                         completion:(void (^)(BOOL finished))completion;
{
    // Are we being asked to re-order view placement to and from the same thing?
    if (incomingViewController == existingViewController) { return; } // Nothing to do.

    APPSAssert([self.childViewControllers containsObject:existingViewController],
    @"The existing view controller '%@' is not already a child of this Container Controller, "
            "and it must be in order to use this method.", existingViewController);

    // Determine if the incoming view controller is already our child:
    BOOL incomingViewControllerAlreadyOurChild = ([self.childViewControllers containsObject:incomingViewController]);

    // Is the incoming view controller already a child of ours?
    if (incomingViewControllerAlreadyOurChild) {
        // YES: We already have this incoming view controller as an active child of ours.
        // Rearrange order in the infoStack to reflect that this incoming
        // controller is now below the existing one specified:
        [self.infoStack reorderEntryForController:incomingViewController
                        belowEntryForController:existingViewController];
        
        // We then need to bracket the view re-ordering with an appearance transition for the
        // newly inserted view controller. This is counter intuitive, but b/c it was inserted below,
        // the presumption is that the existing view controller (which is on top), will be animated
        // out of the way.
        [incomingViewController beginAppearanceTransition:YES animated:YES];
        [self.containerView insertSubview:incomingViewController.view belowSubview:existingViewController.view];
        [incomingViewController endAppearanceTransition];
    }
    else {
        // NO: We need to prepare the incoming view controller to be a child of ours.
        [self prepareIncomingChildViewController:incomingViewController];
        [self addChildViewController:incomingViewController];
        // Record with the infoStack:
        [self.infoStack insertEntryForController:incomingViewController
                        belowEntryForController:existingViewController];
        
        // Since the incoming view controller is new, so beyond adding its view,
        // we need to inform it that it has moved to a parent view controller.
        // The runtime handles appearance callbacks properly, automatically, for such cases.
        [self.containerView insertSubview:incomingViewController.view belowSubview:existingViewController.view];
        [incomingViewController didMoveToParentViewController:self];
    }

    if (completion) { completion(YES); }
}


- (void)placeIncomingViewController:(UIViewController *)incomingViewController
        aboveExistingViewController:(UIViewController *)existingViewController
                         completion:(void (^)(BOOL finished))completion;
{
    // Are we being asked to re-order view placement to and from the same thing?
    if (incomingViewController == existingViewController) { return; } // Nothing to do.

    [self logContentsWithNote:@"Prior to placement above"];

    APPSAssert([self.childViewControllers containsObject:existingViewController],
    @"The existing view controller '%@' is not already a child of this Container Controller, "
            "and it must be in order to use this method.", existingViewController);

    // Determine if the incoming view controller is already our child:
    BOOL incomingViewControllerAlreadyOurChild = ([self.childViewControllers containsObject:incomingViewController]);

    // Is the incoming view controller already a child of ours?
    if (incomingViewControllerAlreadyOurChild) {
        // YES: We already have this incoming view controller as an active child of ours.
        // Rearrange order in the infoStack to reflect that this incoming
        // controller is now above the existing one specified:
        [self.infoStack reorderEntryForController:incomingViewController
                          aboveEntryForController:existingViewController];
        
        // Bracket the view change / layering in appearance transition calls so that the runtime
        // can send appearance callbacks to the incoming view controller and disappearance callbacks
        // to the existing view controller soon to be covered.
        [incomingViewController beginAppearanceTransition:YES animated:YES];
        [existingViewController beginAppearanceTransition:NO  animated:YES];
        [self.containerView insertSubview:incomingViewController.view aboveSubview:existingViewController.view];
        [existingViewController endAppearanceTransition];
        [incomingViewController endAppearanceTransition];
    }
    else {
        // NO: We need to prepare the incoming view controller to be a child of ours.
        [self prepareIncomingChildViewController:incomingViewController];
        [self addChildViewController:incomingViewController];
        // Record with the infoStack:
        [self.infoStack insertEntryForController:incomingViewController
                         aboveEntryForController:existingViewController];
        
        // Make the view change and then advise the new incoming child view controller
        // that it has become our child. This will complete the appearance callback notifications.
        // We must also tell the existing view controller that it is going to disappear, by bracketing
        // this view change with the appropriate appearance transition info.
        [existingViewController beginAppearanceTransition:NO  animated:YES];
        [self.containerView insertSubview:incomingViewController.view aboveSubview:existingViewController.view];
        [incomingViewController didMoveToParentViewController:self];
        [existingViewController endAppearanceTransition];
    }

    [self logContentsWithNote:@"After placement above"];

    if (completion) { completion(YES); }
}


- (void)swapExistingViewController:(UIViewController *)existingViewController
        withIncomingViewController:(UIViewController *)incomingViewController
                        completion:(void (^)(BOOL))completion;
{
    // Are we being asked to re-order view placement to and from the same thing?
    if (incomingViewController == existingViewController) { return; } // Nothing to do.

    APPSAssert([self.childViewControllers containsObject:existingViewController],
    @"The existing view controller '%@' is not already a child of this Container Controller, "
            "and it must be in order to use this method.", existingViewController);

    // Prepare the existing view controller for removal:
    [existingViewController willMoveToParentViewController:nil];

    // Determine if the incoming view controller is already our child:
    BOOL incomingViewControllerAlreadyOurChild = ([self.childViewControllers containsObject:incomingViewController]);

    // Is the incoming view controller already a child of ours?
    if (incomingViewControllerAlreadyOurChild) {
        // YES: We already have this incoming view controller as an active child of ours.
        // Rearrange order in the infoStack to reflect that this incoming
        // controller is now below the existing one specified:
        [self.infoStack replaceEntryForController:existingViewController
                          withExistingController:incomingViewController];
        
        // Place incoming view controller's view on top, and then remove existing view controller's view:
        [self.containerView insertSubview:incomingViewController.view aboveSubview:existingViewController.view];
        [existingViewController.view removeFromSuperview];
    }
    else {
        // NO: We need to prepare the incoming view controller to be a child of ours
        [self prepareIncomingChildViewController:incomingViewController];
        [self addChildViewController:incomingViewController];
        // Record with the infoStack:
        [self.infoStack replaceEntryForController:existingViewController
                           withNewController:incomingViewController];
        
        // Place incoming view controller's view on top, and then remove existing view controller's view:
        [self.containerView insertSubview:incomingViewController.view aboveSubview:existingViewController.view];
        [existingViewController.view removeFromSuperview];

        // Advise the new child controller that we are its parent now:
        [incomingViewController didMoveToParentViewController:self];
    }

    // Formally remove the existing controller from being our child:
    [existingViewController removeFromParentViewController];

    if (completion) { completion(YES); }
}



#pragma mark - Transitions: Push

- (void)pushWithTransitionFromViewController:(UIViewController *)fromViewController
                            toViewController:(UIViewController *)toViewController
                                    duration:(NSTimeInterval)duration
                                   direction:(APPSContainerControllerTransitionDirection)direction
                                     options:(UIViewAnimationOptions)options
                           removeFromAsChild:(BOOL)removeFromAsChild
                                       start:(void (^)(void))start
                                  completion:(void (^)(BOOL))completion;
{
    // Was a fromViewController not specified? It isn't mandatory; we'll just assume the currently visible controller.
    if (!fromViewController) { fromViewController = self.visibleViewController; }

    // Are we being asked to transition to and from the same thing?
    if (fromViewController == toViewController) { return; } // Nothing to do.

    // Notify:
    // Were we asked to remove the previously visible view controller after the transition?
    if (removeFromAsChild) { [fromViewController willMoveToParentViewController:nil]; }

    // Determine if the incoming view controller is already our child:
    BOOL incomingViewControllerAlreadyOurChild = ([self.childViewControllers containsObject:toViewController]);
    
    // Is the incoming view controller already a child of ours?
    if (incomingViewControllerAlreadyOurChild) {
        // YES: We already have this incoming view controller as an active child of ours.
        // Remove earlier entry for the 'to' controller, since we'll add a fresh one shortly:
        [self.infoStack removeEntryForController:toViewController];

        // Bracket positioning with appearance callbacks, given that this is an existing child:
        [toViewController beginAppearanceTransition:YES animated:YES];
        [self prepositionIncomingChildViewController:toViewController direction:direction];
        [toViewController endAppearanceTransition];
    }
    else {
        // NO: We need to prepare the incoming view controller to be a child of ours.
        // Size and Position:
        [self prepareIncomingChildViewController:toViewController];
        [self prepositionIncomingChildViewController:toViewController direction:direction];

        // Formally add the view controller as a child of ours:
        [self addChildViewController:toViewController];
    }

    // Record:
    [self.infoStack addEntryForController:toViewController
                           transitionType:APPSContainerControllerTransitionType_Push
                      transitionDirection:direction];

    // Process pre-transition block, if we were given one:
    if (start) {start();}

    // Transition:
    [self processTransitionFromViewController:fromViewController
                             toViewController:toViewController
                                     duration:duration
                                      options:options
                            removeFromAsChild:removeFromAsChild
                        incomingAlreadyAChild:incomingViewControllerAlreadyOurChild
                                   animations:^{
                                       [self applyDestinationPositionsForSlideTransitionFromViewController:fromViewController
                                                                                          toViewController:toViewController
                                                                                                 direction:direction];
                                   }
                                   completion:completion];
}



#pragma mark - Transitions: Cover

- (void)coverTransitionFromViewController:(UIViewController *)fromViewController
                         toViewController:(UIViewController *)toViewController
                                 duration:(NSTimeInterval)duration
                                direction:(APPSContainerControllerTransitionDirection)direction
                                  options:(UIViewAnimationOptions)options
                        removeFromAsChild:(BOOL)removeFromAsChild
                          fallShortPoints:(CGFloat)fallShortPoints
                                    start:(void (^)(void))start
                               completion:(void (^)(BOOL))completion;
{
    // Was a fromViewController not specified? It isn't mandatory; we'll just assume the currently visible controller.
    if (!fromViewController) { fromViewController = self.visibleViewController; }

    // Are we being asked to transition to and from the same thing?
    if (fromViewController == toViewController) { return; } // Nothing to do.

    // Notify:
    // Were we asked to remove the previously visible view controller after the transition?
    if (removeFromAsChild) { [fromViewController willMoveToParentViewController:nil]; }

    // Determine if the incoming view controller is already our child:
    BOOL incomingViewControllerAlreadyOurChild = ([self.childViewControllers containsObject:toViewController]);

    // Is the incoming view controller already a child of ours?
    if (incomingViewControllerAlreadyOurChild) {
        // YES: We already have this incoming view controller as an active child of ours.
        // Remove existing entry for the 'to' controller since it will be added back in shortly,
        // reflecting this transition:
        [self.infoStack removeEntryForController:toViewController];        
        // Position:
        [self prepositionIncomingChildViewController:toViewController direction:direction];
    }
    else {
        // NO: We need to prepare the incoming view controller to be a child of ours.
        // Size and position:
        [self prepareIncomingChildViewController:toViewController];
        [self prepositionIncomingChildViewController:toViewController direction:direction];
        
        [self addChildViewController:toViewController];
    }
    
    // Record:
    [self.infoStack addEntryForController:toViewController
                           transitionType:APPSContainerControllerTransitionType_Cover
                      transitionDirection:direction];

    // Process pre-transition block, if we were given one:
    if (start) { start(); }

    // Transition:
    [self processTransitionFromViewController:fromViewController
                             toViewController:toViewController
                                     duration:duration
                                      options:options
                            removeFromAsChild:removeFromAsChild
                        incomingAlreadyAChild:incomingViewControllerAlreadyOurChild
                                   animations:^{
        [self applyDestinationPositionForCoverTransitionWithToViewController:toViewController
                                                                   direction:direction
                                                             fallShortPoints:fallShortPoints];
    }                              completion:completion];
}



#pragma mark - Transitions: Reveal

- (void)revealTransitionFromViewController:(UIViewController *)fromViewController
                          toViewController:(UIViewController *)toViewController
                                  duration:(NSTimeInterval)duration
                                 direction:(APPSContainerControllerTransitionDirection)direction
                                   options:(UIViewAnimationOptions)options
                         removeFromAsChild:(BOOL)removeFromAsChild
                           fallShortPoints:(CGFloat)fallShortPoints
                                     start:(void (^)(void))start
                                completion:(void (^)(BOOL))completion;
{
    // Was a fromViewController not specified? It isn't mandatory; we'll just assume the currently visible controller.
    if (!fromViewController) { fromViewController = self.visibleViewController; }

    // Are we being asked to transition to and from the same thing?
    if (fromViewController == toViewController) { return; } // Nothing to do.

    // Determine if the incoming view controller is already our child:
    BOOL incomingViewControllerAlreadyOurChild = ([self.childViewControllers containsObject:toViewController]);

    // Notify:
    // Were we asked to remove the previously visible view controller after the transition?
    if (removeFromAsChild) { [fromViewController willMoveToParentViewController:nil]; }

    // Is the incoming view controller already a child of ours?
    if (incomingViewControllerAlreadyOurChild) {
        // YES: We already have this incoming view controller as an active child of ours.
        // Remove existing entry for the 'to' controller since it will be added back in shortly,
        // reflecting this transition:
        [self.infoStack removeEntryForController:toViewController];
        
        // Now ensure z-index layering has the to-be-revealed existing child controller just under
        // the 'from' controller's view. Bracket that with appearance callbacks.
        [toViewController beginAppearanceTransition:YES animated:YES];
        [self.containerView insertSubview:toViewController.view belowSubview:fromViewController.view];
        [toViewController endAppearanceTransition];
    }
    else {
        // NO: We need to prepare the incoming view controller to be a child of ours.
        // Size:
        [self prepareIncomingChildViewController:toViewController];
        
        // Position the 'to' view controller at and origin off-screen, otherwise it will appear right away:
        [toViewController.view apps_setFrameOrigin:CGPointMake(0, self.containerView.frame.size.height)];

        [self addChildViewController:toViewController]; 
        
        // Just before we animate, place the to-view controller at origin (0,0), so that it can be revealed:
        [toViewController.view apps_setFrameOrigin:CGPointZero];
    }

    // Record:
    [self.infoStack addEntryForController:toViewController
                           transitionType:APPSContainerControllerTransitionType_Reveal
                      transitionDirection:direction];

    // Process pre-transition block, if we were given one:
    if (start) { start(); }

    // Transition:
    [self processTransitionFromViewController:fromViewController
                             toViewController:toViewController
                                     duration:duration
                                      options:options
                            removeFromAsChild:removeFromAsChild
                        incomingAlreadyAChild:incomingViewControllerAlreadyOurChild
            animations:^{
                // Add the child view controller's view to our containerView, below the
                // currently visible view.

                // Note: trying to do this any earlier meant that the reveal effect would not
                // work. Although already added by this point, our insertSubview:belowSubview:
                // call re-orders the layering so that the incoming view controller is on the
                // bottom view layer, which isn't the default behavior.
                [self.containerView insertSubview:toViewController.view
                                     belowSubview:fromViewController.view];

                // Move the 'from' to the appropriate place.
                [self applyDestinationPositionForRevealTransitionWithFromViewController:fromViewController
                                                                              direction:direction
                                                                        fallShortPoints:fallShortPoints];
            }
            completion:completion];
}



#pragma mark - Transitions: Modal

- (void)presentModalViewController:(UIViewController *)modalViewController
                          animated:(BOOL)animated
                        completion:(void (^)(BOOL))completion;
{
    // Is the modal view controller already being displayed by us?
    if (modalViewController.parentViewController == self) {
        // YES: Nothing to do; the modalViewController already has us as its parent.
        return;
    }
    
    // Assertion: We're going to add the modalViewController formally, as our child controller,
    // and also add its view.

    // Prepare:
    [self prepareIncomingChildViewController:modalViewController];

    // Notify:
    [self addChildViewController:modalViewController]; // Add the controller part; the 'willMoveToParentViewController' will be called for us, on the child controller
    
    // Position View:
    [modalViewController.view apps_setFrameOriginY:CGRectGetMaxY(self.containerView.bounds)];
    [self.containerView addSubview:modalViewController.view];
  
    // Animate up:
    [UIView animateWithDuration:(animated ? 0.35 : 0.0)
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         [modalViewController.view apps_setFrameOriginY:0];
                     }
                     completion:^(BOOL finished) {
                         NSLog(@"completed modal presentation of controller: %@", modalViewController);
                         if (finished) {
                             // Notify the child that the move is done:
                             [modalViewController didMoveToParentViewController:self];

                             // Have the previously visible child controller marked as modally covered:
                             if (self.infoStack.lastEntry) {
                                 self.infoStack.lastEntry.modallyCovered = YES;
                             }

                             // Add an entry to keep track of the latest child view controller added:
                             [self.infoStack addEntryForController:modalViewController
                                                    transitionType:APPSContainerControllerTransitionType_Modal
                                               transitionDirection:APPSContainerControllerTransitionDirection_Up];
                             [self setNeedsStatusBarAppearanceUpdate];

                             if (completion) { completion(YES); };
                         }
                     }];
}


- (void)dismissModalViewControllerAnimated:(BOOL)animated completion:(void (^)(BOOL))completion {
    logDebug(@"");

    // Retrieve the entry and actual controller:
    APPSViewControllerInfoStackEntry *lastEntry = [self.infoStack lastEntry];
    UIViewController *controllerToDismiss = [lastEntry controller];

    // NOTE: We don't enforce that the child view controller we are about to animate a dismissal of was last
    // transitioned onto the screen modally, because while it may have been at the start, it may have also just
    // slid side to side with another view controller and thus, lost is original modal presentation transition flag.

    // Ensure we have a controller to dismiss:
    if (!controllerToDismiss) {
        logWarn(@"Asked to dismiss a modal view controller when we have no view controller to dismiss.");
        return;
    }
    
    // Checkpoint: We know we have a modal view controller that we can dismiss.
    
    // Ensure the controller we will return to, is positioned at origin {0,0}, since these seem to have moved on us!
    UIViewController *controllerReturnedTo = [self childViewControllerToReturnToForModalDismissal];
    if (controllerReturnedTo) {
        [controllerReturnedTo.view apps_setFrameOrigin:CGPointZero];
    }
    
    logInfo(@"Return controller view: %@", controllerReturnedTo.view);

    
    
    // Notify:
    [controllerToDismiss willMoveToParentViewController:nil];
    
    // Determine desired ending position:
    CGFloat dismissalOriginY = CGRectGetMaxY(self.containerView.bounds);

    __weak APPSContainerViewController *weakSelf = self;

    // Animate down:
    [UIView animateWithDuration:(animated ? 0.35 : 0.0)
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseOut |
                                 UIViewAnimationOptionAllowUserInteraction |
                                 UIViewAnimationOptionAllowAnimatedContent)
                     animations:^{
                         [controllerToDismiss.view apps_setFrameOriginY:dismissalOriginY];
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             // Remove the child's view from the container:
                             [controllerToDismiss.view removeFromSuperview];

                             // Notify the child that the move is done:
                             [controllerToDismiss removeFromParentViewController];
                             [weakSelf.infoStack removeEntryForController:controllerToDismiss];
                             [weakSelf logContentsWithNote:@"Just completed modal dismissal."];

                             [self setNeedsStatusBarAppearanceUpdate];

                             if (completion) { completion(YES); };
                         }
                     }];
}



@end
