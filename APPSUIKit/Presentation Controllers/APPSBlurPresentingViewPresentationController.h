//
//  APPSBlurPresentingViewPresentationController.h
//
//  Created by Sohail Ahmed on 1/14/16.
//

#import <UIKit/UIKit.h>


#pragma mark - Constants

/**
 Note that the sum of the delay and duration must be less than or equal to your
 Animated Transitioning controller's presentation duration.
 */
#pragma mark * Default Timings: Presentation

static const NSTimeInterval kAPPSBlurPresentingViewPresentation_DefaultPresentationDelay    = 0.0;
static const NSTimeInterval kAPPSBlurPresentingViewPresentation_DefaultPresentationDuration = 0.2;

/**
 Note that the sum of the delay and duration must be less than or equal to your
 Animated Transitioning controller's dismissal duration.
 */
#pragma mark * Default Timings: Dismissal

static const NSTimeInterval kAPPSBlurPresentingViewPresentation_DefaultDismissingDelay      = 0.3;
static const NSTimeInterval kAPPSBlurPresentingViewPresentation_DefaultDismissingDuration   = 0.2;

#pragma mark * Dimming and Blurring

static const CGFloat kAPPSBlurPresentingViewPresentation_DefaultPresentingViewDimmingAlpha  = 0.3;
static const CGFloat kAPPSBlurPresentingViewPresentation_DefaultPresentingViewBlurRadius    = 20.0;
static const CGFloat kAPPSBlurPresentingViewPresentation_DefaultPresentingViewScale         = 1.0;


/**
 This custom Presentation Controller will blur the presenting view controller's top level view.
 
 For this effect to work, the @c presentingViewController should have a top-level UIImageView
 somewhere in its hierarchy. We'll traverse the view hierarchy and use the largest UIImageView 
 that we find for this purpose.
 
 We are looking to use the image in that @c UIImageView as the basis for our blur calculations.

 Several default timing, blurring and dimming constants are provided, but you may override
 properties for the same to fine tune this presentation controller to your needs.
 */
@interface APPSBlurPresentingViewPresentationController : UIPresentationController

#pragma mark scalar

/**
 During presentation of a view controller, this is the delay incurred before 
 the presentation animation begins.
 
 Defaults to: @c kAPPSBlurPresentingViewPresentation_DefaultPresentationDelay.
 */
@property (assign, nonatomic) NSTimeInterval presentationDelay;


/**
 This is the duration for the animation that presents the incoming view controller.
 
 Defaults to: @c kAPPSBlurPresentingViewPresentation_DefaultPresentationDuration.
 */
@property (assign, nonatomic) NSTimeInterval presentationDuration;


/**
 During dismissal of a view controller, this is the delay incurred before
 the dismissal animation begins.
 
 Defaults to: @c kAPPSBlurPresentingViewPresentation_DefaultDismissingDelay.
 */
@property (assign, nonatomic) NSTimeInterval dismissalDelay;


/**
 This is the duration for the animation that dismisses the outgoing view controller.
 
 Defaults to: @c kAPPSBlurPresentingViewPresentation_DefaultDismissingDuration.
 */
@property (assign, nonatomic) NSTimeInterval dismissalDuration;


/**
 This is the alpha of the presenting view during presentation of an incoming view controller.
 The idea being, that you likely want some degree of dimming of the current view controller
 (i.e. the 'presenting' view controller). Note that we animate this dimming, as we do the blurring
 of the presenting view controller.
 
 Defaults to: @c kAPPSBlurPresentingViewPresentation_DefaultPresentingViewDimmingAlpha.
 */
@property (assign, nonatomic) CGFloat presentingViewDimmingAlpha;


/**
 Working hand in hand with @c presentingViewDimmingAlpha, this is how far out any pixel is averaged
 by its neighbouring pixels to create a blur effect. This applies to the presenting view controller,
 whom we are diffusing, so as to bring the focus on the incoming ('presented') view controller.
 
 Defaults to: @c kAPPSBlurPresentingViewPresentation_DefaultPresentingViewBlurRadius.
 */
@property (assign, nonatomic) CGFloat presentingViewBlurRadius;


/**
 Optional. Defaults to 1.0 (no scaling). Represents what scaling factor we are to apply to
 the source (presenting) view controller (whose view is the one that gets blurred) before
 the incoming (presented) view controller is placed on top.
 
 Defaults to: @c kAPPSBlurPresentingViewPresentation_DefaultPresentingViewScale.
 */
@property (assign, nonatomic) CGFloat presentingViewScale;

@end
