//
//  APPSSimplePresentationController.m
//
//  Created by Sohail Ahmed on 8/15/15.
//

@import APPSFoundation;

#import "APPSSimplePresentationController.h"


@interface APPSSimplePresentationController ()
@property (nonatomic, strong) UIView *dimmingView;
@end


@implementation APPSSimplePresentationController


- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController;
{
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        self.enableDimming = YES; // Our default
    }
    
    return self;
}


#pragma mark - Configuration

- (UIView *)dimmingView
{
    if (!_dimmingView) {
        _dimmingView = [[UIView alloc] init];
        
        UIColor *backgroundColor;
        
        if (self.enableDimming) {
            backgroundColor = UIColorFromRGBWithAlpha(0x000000, 0.5f);
        }
        else {
            backgroundColor = [UIColor clearColor];
        }
        
        _dimmingView.backgroundColor = backgroundColor;
    }
    
    return _dimmingView;
}


- (void)presentationTransitionWillBegin
{
    self.dimmingView.frame = self.containerView.bounds;
    self.dimmingView.alpha = 0.0;
    [self.containerView addSubview:self.dimmingView];
    
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        // Fade the dimming view to be fully visible
        
        self.dimmingView.alpha = 1.0;
    } completion:nil];
}


- (void)presentationTransitionDidEnd:(BOOL)completed
{
    // Remove the dimming view if the presentation was aborted.
    if (!completed) {
        [self.dimmingView removeFromSuperview];
    }
}


- (void)dismissalTransitionWillBegin
{
    // Here, we'll undo what we did in -presentationTransitionWillBegin. Fade the dimming view to be fully transparent
    
    [self.presentedViewController.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.dimmingView.alpha = 0.0;
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        [self.dimmingView removeFromSuperview];
    }];
}


@end
