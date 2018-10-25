//
//  APPSBlurPresentingViewPresentationController.m
//
//  Created by Sohail Ahmed on 1/14/16.
//

#import "APPSBlurPresentingViewPresentationController.h"
#import "UIImageEffects.h"
#import "UIView+Appstronomy.h"


@interface APPSBlurPresentingViewPresentationController ()
@property (nonatomic, strong) UIView *dimmingView;
@end



@implementation APPSBlurPresentingViewPresentationController

#pragma mark - Initialization

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController *)presentingViewController;
{
    self = [super initWithPresentedViewController:presentedViewController
                         presentingViewController:presentingViewController];
    
    if (self) {
        // Apply defaults to properties callers can later adjust themselves:
        [self applyDefaults];
    }
    
    return self;
}



- (UIView *)dimmingView
{
    if (!_dimmingView) {
        
        UIColor *tintColor = [[UIColor blackColor] colorWithAlphaComponent:self.presentingViewDimmingAlpha];
        
        // create the composite background image and blur it
        UIImage *compositeImage = [self compositeBackgroundImage];
        
        compositeImage = [UIImageEffects appl_imageByApplyingBlurToImage:compositeImage
                                                              withRadius:self.presentingViewBlurRadius
                                                               tintColor:tintColor
                                                   saturationDeltaFactor:1.0
                                                               maskImage:nil];
        
        _dimmingView = [[UIImageView alloc] initWithImage:compositeImage];
    }
    return _dimmingView;
}


- (UIImage *)compositeBackgroundImage
{
    UIImageView *backgroundImageView = [self largestImageViewForController:self.presentingViewController];
    
    UIImage *compositeImage;
    UIImage *backgroundImage = backgroundImageView.image;
    UIImage *screenshotOfPresentingViewController = [self screenshotOfPresentingViewController];   
    
    CGSize presentingViewControllerViewSize = self.presentingViewController.view.bounds.size;
    
    CGPoint homeTopLeft;
    homeTopLeft.x = (CGFloat)((backgroundImage.size.width - presentingViewControllerViewSize.width) / 2.0);
    homeTopLeft.y = (CGFloat)((backgroundImage.size.height - presentingViewControllerViewSize.height) / 2.0);
    
    UIGraphicsBeginImageContextWithOptions(backgroundImage.size, YES, 1); // We don't need full retina resolution, since were going to blur it anyway.
    [backgroundImage drawAtPoint:CGPointZero];
    [screenshotOfPresentingViewController drawAtPoint:homeTopLeft];
    compositeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return compositeImage;
}


- (UIImage *)screenshotOfPresentingViewController
{
    UIView *homeView = self.presentingViewController.view;
    CGSize size = homeView.bounds.size;
    
    UIGraphicsBeginImageContextWithOptions(size, YES, 1); // don't need full retina resolution if were going to blur it anyway
    
    // Setting this last parameter to YES causes the animation delays to be ignored in Transitioning:
    [homeView drawViewHierarchyInRect:CGRectMake(0.0, 0.0, size.width, size.height) afterScreenUpdates:NO];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}



#pragma mark - Defaults

- (void)applyDefaults;
{
    self.presentationDelay          = kAPPSBlurPresentingViewPresentation_DefaultPresentationDelay;
    self.presentationDuration       = kAPPSBlurPresentingViewPresentation_DefaultPresentationDuration;
    self.dismissalDelay             = kAPPSBlurPresentingViewPresentation_DefaultDismissingDelay;
    self.dismissalDuration          = kAPPSBlurPresentingViewPresentation_DefaultDismissingDuration;
    self.presentingViewDimmingAlpha = kAPPSBlurPresentingViewPresentation_DefaultPresentingViewDimmingAlpha;
    self.presentingViewBlurRadius   = kAPPSBlurPresentingViewPresentation_DefaultPresentingViewBlurRadius;
    self.presentingViewScale        = kAPPSBlurPresentingViewPresentation_DefaultPresentingViewScale;
}



#pragma mark - UIPresentationController Methods

#pragma mark * Presentation

- (void)presentationTransitionWillBegin
{
    CGRect containerBounds = self.containerView.bounds;
    CGPoint containerCenter = CGPointMake(CGRectGetMidX(containerBounds), CGRectGetMidY(containerBounds));
    
    // position dimming view
    self.dimmingView.alpha = 0.0;
    self.dimmingView.center = containerCenter;
    
    // add views to hierarchy
    [self.containerView addSubview:self.dimmingView];
    [self.containerView addSubview:self.presentedViewController.view];
    
    self.presentedViewController.view.backgroundColor = [UIColor clearColor];
    
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        UIViewAnimationOptions options = UIViewAnimationOptionCurveEaseOut;
        CGAffineTransform scalingTransform = CGAffineTransformMakeScale(self.presentingViewScale, self.presentingViewScale);
        
        [UIView animateWithDuration:self.presentationDuration
                              delay:self.presentationDelay
                            options:options
                         animations:^{
                             
                             // fade out presenting view
                             self.presentingViewController.view.alpha = 0.0;
                             self.presentingViewController.view.transform = scalingTransform;
                             
                             // fade in dimming view
                             self.dimmingView.alpha = 1.0;
                             self.dimmingView.transform = scalingTransform;
                         } completion:nil];
        
    } completion:nil];
}


- (void)presentationTransitionDidEnd:(BOOL)completed
{
    // Remove the dimming view if the presentation was aborted.
    if (!completed) {
        [self.dimmingView removeFromSuperview];
    }
}


#pragma mark * Dismissal

- (void)dismissalTransitionWillBegin
{
    // Here, we'll undo what we did in -presentationTransitionWillBegin. Fade the dimming view to be fully transparent
    
    // Use animateAlongsideTransitionInView:animation:completion because presentingViewController.view is not in hierarchy of self.containerView
    [self.presentingViewController.transitionCoordinator animateAlongsideTransitionInView:self.containerView.window
                                                                                animation:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        // OverrideInherited options must be specified to use the new duration and delay for this animation.
        // Otherwise the dimmingView animation happens to late.
        UIViewAnimationOptions options = (UIViewAnimationOptionCurveEaseIn |
                                          UIViewAnimationOptionOverrideInheritedCurve |
                                          UIViewAnimationOptionOverrideInheritedDuration );
        CGAffineTransform scalingTransform = CGAffineTransformIdentity;
        
        [UIView animateWithDuration:self.dismissalDuration
                              delay:self.dismissalDelay
                            options:options
                         animations:^{
                             
                             // fade in presenting view
                             self.presentingViewController.view.alpha = 1.0;
                             self.presentingViewController.view.transform = scalingTransform;
                             
                             // fade out dimming view
                             self.dimmingView.alpha = 0.0;
                             self.dimmingView.transform = scalingTransform;
                             
                         } completion:nil];
        
    } completion:nil];
    
}


- (void)dismissalTransitionDidEnd:(BOOL)completed
{
    [self.dimmingView removeFromSuperview];
}



#pragma mark - Helpers

/**
 Finds the largest UIImageView in the specified controller's view hierarchy.
 
 @param controller The controller to go looking in.
 
 @return The UIImageView; not the image. Callers need to ask for the image from this provided UIImageView.
 */
- (UIImageView *)largestImageViewForController:(UIViewController *)controller;
{
    UIView *topLevelView = controller.view;
    NSSet *imageViews = [self imageViewsInViewHierarchy:topLevelView];
    
    CGFloat largestViewArea = 0;
    UIImageView *largestImageView = nil;
    
    for (UIImageView *iteratedImageView in imageViews) {
        CGFloat viewArea = (iteratedImageView.frame.size.width * iteratedImageView.frame.size.height);
        
        // Did we find a larger image view, which also actually has an image set?
        if (viewArea > largestViewArea && iteratedImageView.image) {
            largestViewArea = viewArea;
            largestImageView = iteratedImageView;
        }
    }
    
    return largestImageView;
}


- (NSSet *)imageViewsInViewHierarchy:(UIView *)topLevelView;
{
    NSMutableSet<UIImageView *> *imageViews = [NSMutableSet setWithCapacity:10];

    [topLevelView apps_runBlockOnAllSubviews:^(UIView *view) {
        if ([view isKindOfClass:[UIImageView class]]) {
            [imageViews addObject:(UIImageView *)view];
        }
    }];
    
    return imageViews;
}




@end
