//
//  APPSSimpleActivityStatusViewController.m
//
//  Created by Sohail Ahmed on 11/12/15.
//

@import APPSFoundation;

#import "APPSSimpleActivityStatusViewController.h"
#import "APPSSimplePresentationController.h"
#import "UIColor+Appstronomy.h"
#import "UIView+Appstronomy.h"
#import <APPSUIKit/APPSUIKit-Swift.h>

@interface APPSSimpleActivityStatusViewController () <UIViewControllerTransitioningDelegate>

#pragma mark scalar

/**
 We use this to determine if the activity indicator @em should be active. Sometimes,
 callers can call our @c -startAnimatingActivityIndicator method too early. That's why
 under the hood, we set this value so that on @c -viewDidLoad, we know to trigger that 
 activity indicator movement again.
 */
@property (assign, nonatomic) BOOL activityIndicatorActive;


#pragma mark strong

/**
 We'll possibly install/uninstall this optional blur effect view, so we'll
 keep a strong reference to it.
 */
@property (strong, nonatomic) UIVisualEffectView *blurEffectView;

/**
 Whenever we create new centering constraints for the dialogView, we'll keep track of
 them here. That way, if an adjusted set needs to be created, we can first remove
 the existing set.
 */
@property (strong, nonatomic) NSArray *dialogViewCenteringConstraints;


#pragma mark outlets

// weak
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dialogViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dialogViewHeightConstraint;

// strong
@property (strong, nonatomic) IBOutlet UIView *dialogView;

@end


@implementation APPSSimpleActivityStatusViewController

#pragma mark - Instantiation

+ (instancetype)activityController;
{
    return [[[self class] alloc] initWithNibName:@"APPSBlurBasedActivityStatusViewController"
                                          bundle:[APPSUIKit bundle]];
}



#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return  self;
}


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return  self;
}


- (void)commonInit
{
    self.transitioningDelegate = self;
    self.modalPresentationStyle = UIModalPresentationCustom;
    
    [self applyDefaults];
}


- (void)applyDefaults;
{
    self.dialogViewBackgroundColor       = UIColorFromRGB(kAPPSColorHex_DIALOG_WHITE);
    self.blurEffectStyle                 = kAPPSSimpleActivityStatus_DefaultBlurEffectStyle;
    self.dialogWidth                     = kAPPSSimpleActivityStatus_DefaultDialogWidth;
    self.dialogHeight                    = kAPPSSimpleActivityStatus_DefaultDialogHeight;
    self.dialogHorizontalCenteringOffset = kAPPSSimpleActivityStatus_DefaultDialogHorizontalCenteringOffset;
    self.dialogVerticalCenteringOffset   = kAPPSSimpleActivityStatus_DefaultDialogVerticalCenteringOffset;
}


#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configure];
}


- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    // Applying this rounding earlier won't work. We need everything layout wise, to have settled
    // before a rounding attempt will hold:
    [self.blurEffectView apps_roundCorners:UIRectCornerAllCorners radius:kAPPSSimpleActivityStatus_DefaultRoundedCornerRadius];
    [self.dialogView apps_roundCorners:UIRectCornerAllCorners radius:kAPPSSimpleActivityStatus_DefaultRoundedCornerRadius];
}



#pragma mark - Configuration

/**
 The main configuration method. We delegate to other more granular configuration methods.
 */
- (void)configure;
{
    [self configureMainView];
    [self configureDialogView];
    
    if (self.useBlurEffectBackground) {
        [self configureWithBlurEffectView];
    }
    else {
        [self configureWithoutBlurEffectView];
    }
    
    [self.view setNeedsUpdateConstraints];
    [self.view setNeedsLayout];
}


/**
 Configures the top-level view associated with this View Controller.
 */
- (void)configureMainView;
{
    // Set the main background to be clear. We don't do this in the Storyboard,
    // because it makes other elements in the scene difficult to see at design time.
    self.view.backgroundColor = [UIColor clearColor];
}


- (void)configureDialogView;
{
    // Internals
    self.messageLabel.text = self.messageText;
    [self updateActivityIndicator];

    // Hierarchy
    [self.dialogView removeFromSuperview];
    [self.view addSubview:self.dialogView];

    // Constraints
    self.dialogViewWidthConstraint.constant = self.dialogWidth;
    self.dialogViewHeightConstraint.constant = self.dialogHeight;
}


/**
 Configures the dialogView for use without the blurEffectView.
 */
- (void)configureWithoutBlurEffectView;
{
    // Apply the non-clear color for the dialogView:
    self.dialogView.backgroundColor = self.dialogViewBackgroundColor;
    
    // Discard the blurEffectView:
    [self.blurEffectView removeFromSuperview];
    self.blurEffectView = nil;
    
    // Apply centering constraints between dialogView and top-level view:
    [self configureCenteringConstraintsOnDialogView];
}


/**
 Configures both the dialogView and blurEffectView, knowing that a blurEffectView will be
 used as the superview of the dialogView.
 
 As always, the size and position of the dialogView is what drives the layout; the blurEffectView
 merely shadows the size and position the dialogView is set to.
 */
- (void)configureWithBlurEffectView;
{
    // Set dialogView to a clear color, given that it will now go inside the blurEffectView:
    self.dialogView.backgroundColor = [UIColor clearColor];

    // --- View Hierarchy ---
    // Start fresh; remove dialogView from possibly our top-level view being its superview:
    [self.dialogView removeFromSuperview];

    // Add the blurring effect view to our main view (constraints will be handled later):
    [self.view addSubview:self.blurEffectView];

    // Place the dialogView inside the blurEffectView's contentView:
    [self.blurEffectView.contentView addSubview:self.dialogView];

    // --- Auto-Layout Constraints ---
    // Tie the size of the blurEffectView to the size of the dialogView:
    [self.dialogView apps_addConstraintsToSizeEqualWithSuperview];

    // Center the dialogView with respect to the top-level view, even thought that's not
    // it's immediate superview. This positioning will be followed by the blurEffectView below.
    [self configureCenteringConstraintsOnDialogView];

    // This constraint will tie the dialogView and blurEffectView to the same position
    // on screen. The dialogView already has centering constraints with optional offsets,
    // that the blurEffectView will now mimic, being tied to the dialogView:
    [self.dialogView apps_addConstraintsToCenterWithSuperview];

    // Force the screen to update and reflect these changes:
    [self.view setNeedsUpdateConstraints];
    [self.view setNeedsLayout];
}


/**
 Removes and re-applies a fresh set of horizontal and vertical centering constraints between
 the dialogView and our top-level view. Takes into account that horizontal, vertical or both
 centering constraints are possible.
 */
- (void)configureCenteringConstraintsOnDialogView;
{
    // dialogView: Center in top level view, applying any offsets requested.
    // First, remove any existing centering constraints:
    [self.dialogView removeConstraints:self.dialogViewCenteringConstraints];
    
    // Now apply new constraint:
    self.dialogViewCenteringConstraints = [self.dialogView apps_addConstraintsToCenterWithView:self.view
                                                                                       xOffset:self.dialogHorizontalCenteringOffset
                                                                                       yOffset:self.dialogVerticalCenteringOffset];
}



#pragma mark - Property Overrides

- (void)setUseBlurEffectBackground:(BOOL)useBlurEffectBackground;
{
    if (_useBlurEffectBackground != useBlurEffectBackground) {
        _useBlurEffectBackground = useBlurEffectBackground;
        
        [self configure];
    }
}


- (UIVisualEffectView *)blurEffectView;
{
    if (!_blurEffectView) {
        // Create the effect:
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:self.blurEffectStyle];
        
        // Add the blur effect to an effect view:
        _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        
        // Turn off auto-resizing mask constraints, since we built this programmatically:
        _blurEffectView.translatesAutoresizingMaskIntoConstraints = NO;
        _blurEffectView.contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [_blurEffectView.contentView apps_addConstraintsToCenterWithSuperview];
        [_blurEffectView.contentView apps_addConstraintsToSizeEqualWithSuperview];
    }
    
    return _blurEffectView;
}


- (void)setActivityIndicatorColor:(UIColor *)activityIndicatorColor;
{
    if (_activityIndicatorColor != activityIndicatorColor) {
        _activityIndicatorColor = activityIndicatorColor;
        
        // Were we given a special color to use for the activity indicator view,
        // perhaps even nil to go back to the default. Regardless, set it now:
        self.activityIndicator.color = _activityIndicatorColor;
    }
}


- (void)setMessageText:(NSString *)messageText;
{
    if (_messageText != messageText) {
        _messageText = messageText;
        
        self.messageLabel.text = _messageText;
    }
}


- (void)setDialogWidth:(CGFloat)dialogWidth;
{
    if (_dialogWidth != dialogWidth) {
        _dialogWidth = dialogWidth;
        
        [self configure];
    }
}


- (void)setDialogHeight:(CGFloat)dialogHeight;
{
    if (_dialogHeight != dialogHeight) {
        _dialogHeight = dialogHeight;
        
        [self configure];
    }
}


- (void)setDialogVerticalCenteringOffset:(CGFloat)dialogVerticalCenteringOffset
{
    if (_dialogVerticalCenteringOffset != dialogVerticalCenteringOffset) {
        _dialogVerticalCenteringOffset = dialogVerticalCenteringOffset;

        [self configure];
    }
}


- (void)setDialogHorizontalCenteringOffset:(CGFloat)dialogHorizontalCenteringOffset
{
    if (_dialogHorizontalCenteringOffset != dialogHorizontalCenteringOffset) {
        _dialogHorizontalCenteringOffset = dialogHorizontalCenteringOffset;

        [self configure];
    }
}


#pragma mark - Requests

- (void)startAnimatingActivityIndicator;
{
    self.activityIndicatorActive = YES;
    [self.activityIndicator startAnimating];
}


- (void)stopAnimatingActivityIndicator;
{
    self.activityIndicatorActive = NO;
    [self.activityIndicator stopAnimating];
}



#pragma mark - Update Helpers

- (void)updateActivityIndicator;
{
    self.activityIndicator.color = self.activityIndicatorColor;

    if (self.activityIndicatorActive) {
        [self.activityIndicator startAnimating];
    }
    else {
        [self.activityIndicator stopAnimating];
    }
}



#pragma mark - Protocol: UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source
{
    APPSSimplePresentationController *presentationController = [[APPSSimplePresentationController alloc]
                                                                 initWithPresentedViewController:presented
                                                                 presentingViewController:presenting];
    
    
    // Only turn on dimming if we're not using a blurring effect background to the dialog view:
    presentationController.enableDimming = !self.useBlurEffectBackground;
    
    return presentationController;
}



@end
