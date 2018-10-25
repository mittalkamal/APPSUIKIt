//
//  APPSActivityStatusViewController.m
//
//  Created by Sohail Ahmed on 8/15/15.
//

#import "APPSActivityStatusViewController.h"
#import "APPSSimplePresentationController.h"
#import "UIView+Appstronomy.h"
#import <APPSUIKit/APPSUIKit-Swift.h>

@interface APPSActivityStatusViewController () <UIViewControllerTransitioningDelegate>
// weak: views
@property (weak, nonatomic) IBOutlet UIView *dialogView;
@property (weak, nonatomic) IBOutlet UIView *contentBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *messageTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageBody1Label;
@property (weak, nonatomic) IBOutlet UILabel *messageBody2Label;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

// strong: constraints
@property (strong, nonatomic) NSLayoutConstraint *squareDimensionsConstraint;
@property (strong, nonatomic) NSLayoutConstraint *fixedWidthConstraint; // applied when square dimensions are requested

// weak: constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTitleHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *activityIndicatorHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageBody1HeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageBody2HeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cancelButtonToActionButtonVerticalSpacerConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionButtonToContentBackgroundVerticalConstraint;

// weak: constraints: vertical spacers
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aboveMessageTitleVerticalSpacerConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aboveMessageBody1VerticalSpacerConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aboveActivityIndicatorVerticalSpacerConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aboveMessageBody2VerticalSpacerConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aboveActionButtonVerticalSpacerConstraint;

// scalar: constraint vertical spacer constants
@property (assign, nonatomic) CGFloat defaultAboveMessageTitleVerticalSpacerHeight;
@property (assign, nonatomic) CGFloat defaultAboveMessageBody1VerticalSpacerHeight;
@property (assign, nonatomic) CGFloat defaultAboveActivityIndicatorVerticalSpacerHeight;
@property (assign, nonatomic) CGFloat defaultAboveMessageBody2VerticalSpacerHeight;
@property (assign, nonatomic) CGFloat defaultAboveActionButtonVerticalSpacerHeight;

// scalar: default view heights
@property (assign, nonatomic) CGFloat defaultActivityIndicatorHeight;
@property (assign, nonatomic) CGFloat defaultActionButtonHeight;
@property (assign, nonatomic) CGFloat defaultCancelButtonHeight;

@end


@implementation APPSActivityStatusViewController

#pragma mark - Instantiation

+ (instancetype)activityController;
{
    return [[[self class] alloc] initWithNibName:@"APPSActivityStatusViewController"
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
}



#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set the main background to be clear. We don't do this in the Storyboard,
    // because it makes other elements in the scene difficult to see at design time.
    self.view.backgroundColor = [UIColor clearColor];

    [self recordDefaultConstraintConstants];
    [self updateView];
}


- (void)viewDidLayoutSubviews;
{
    [super viewDidLayoutSubviews];
    
    [self configureDialogBorderAndRounding];
    [self configureContentBackgroundView];
    
    if (self.animateActivityIndicator) {
        [self startAnimatingActivityIndicator];
    }
    else {
        [self stopAnimatingActivityIndicator];
    }
}



#pragma mark - Configuration

- (void)configureDialogBorderAndRounding;
{
    // Round the corners and add a stroke color. We do this here instead of in viewDidLoad,
    // because our layer based modifications won't draw correctly until all of the layout is done.
    [self.dialogView apps_roundCorners:UIRectCornerAllCorners radius:20.0f];
    [self.dialogView apps_strokeMaskPathWithBorderWidth:[UIView apps_hairlineThickness] borderColor:[UIColor blackColor]];
}


- (void)configureContentBackgroundView;
{
    if ([self hasAnActiveButton]) {
        self.contentBackgroundView.hidden = NO;
        self.dialogView.backgroundColor = [UIColor clearColor];
    }
    else {
        self.contentBackgroundView.hidden = YES;
        self.dialogView.backgroundColor = [UIColor whiteColor];
    }
}


- (void)recordDefaultConstraintConstants;
{
    // Spacer Heights:
    self.defaultAboveMessageTitleVerticalSpacerHeight = self.aboveMessageTitleVerticalSpacerConstraint.constant;
    self.defaultAboveMessageBody1VerticalSpacerHeight = self.aboveMessageBody1VerticalSpacerConstraint.constant;
    self.defaultAboveActivityIndicatorVerticalSpacerHeight = self.aboveActivityIndicatorVerticalSpacerConstraint.constant;
    self.defaultAboveMessageBody2VerticalSpacerHeight = self.aboveMessageBody2VerticalSpacerConstraint.constant;
    self.defaultAboveActionButtonVerticalSpacerHeight = self.aboveActionButtonVerticalSpacerConstraint.constant;
    
    // View Heights:
    self.defaultActivityIndicatorHeight = self.activityIndicatorHeightConstraint.constant;
    self.defaultActionButtonHeight = self.actionButtonHeightConstraint.constant;
    self.defaultCancelButtonHeight = self.cancelButtonHeightConstraint.constant;
}


- (void)applyDefaults;
{
    self.messageTitleText = nil;
    self.messageBody1Text = nil;
    self.messageBody2Text = nil;
    self.actionButtonTitleText = nil;
    self.cancelButtonTitleText = nil;
    self.showActivityIndicator = NO;
    self.animateActivityIndicator = NO;
    self.useSquareDimensions = NO;
}


- (void)updateView;
{
    // Load view outlets from backing text properties:
    self.messageTitleLabel.text = self.messageTitleText;
    self.messageBody1Label.text = self.messageBody1Text;
    self.messageBody2Label.text = self.messageBody2Text;
    [self.actionButton setTitle:self.actionButtonTitleText forState:UIControlStateNormal];
    [self.cancelButton setTitle:self.cancelButtonTitleText forState:UIControlStateNormal];
    
    // Activate/Deactivate text constraints:
    [self adjustActivationOfConstraint:self.messageTitleHeightConstraint givenText:self.messageTitleText];
    [self adjustActivationOfConstraint:self.messageBody1HeightConstraint givenText:self.messageBody1Text];
    [self adjustActivationOfConstraint:self.messageBody2HeightConstraint givenText:self.messageBody2Text];

    // Activate/Deactivate button constraints:
    [self adjustButtonConstraints];

    [self adjustVerticalSpacingConstraints];
    
    if (self.showActivityIndicator) {
        self.activityIndicatorHeightConstraint.constant = self.defaultActivityIndicatorHeight;
    }
    else {
        self.activityIndicatorHeightConstraint.constant = 0;
    }
    
    [self adjustSquareDimensionsConstraint];
    
    [self.view setNeedsUpdateConstraints];
    [self.view setNeedsLayout];
    [self.view setNeedsDisplay];
}


- (void)adjustActivationOfConstraint:(NSLayoutConstraint *)constraint givenText:(NSString *)text;
{
    if ([text apps_hasContent]) {
        constraint.active = NO;
    }
    else {
        constraint.constant = 0;
        constraint.active = YES;
    }
}


- (void)adjustButtonConstraints;
{
    if ([self.actionButtonTitleText apps_hasContent]) {
        self.actionButtonHeightConstraint.constant = self.defaultActionButtonHeight;
    }
    else {
        self.actionButtonHeightConstraint.constant = 0;
    }
    
    if ([self.cancelButtonTitleText apps_hasContent]) {
        self.cancelButtonHeightConstraint.constant = self.defaultCancelButtonHeight;
    }
    else {
        self.cancelButtonHeightConstraint.constant = 0;
    }
}


- (void)adjustVerticalSpacingConstraints;
{
    // Hairline Vertical Spacers between buttons:
    self.cancelButtonToActionButtonVerticalSpacerConstraint.constant = [UIView apps_hairlineThickness];
    self.actionButtonToContentBackgroundVerticalConstraint.constant = [UIView apps_hairlineThickness];
    
    // Message Title Text
    if ([self.messageTitleText apps_hasContent]) {
        self.aboveMessageTitleVerticalSpacerConstraint.constant = self.defaultAboveMessageTitleVerticalSpacerHeight;
    }
    else {
        self.aboveMessageTitleVerticalSpacerConstraint.constant = 0;
        if (![self.messageBody1Text apps_hasContent]) {
            self.aboveMessageBody1VerticalSpacerConstraint.constant = 0;
        }
        else {
            self.aboveMessageBody1VerticalSpacerConstraint.constant = self.defaultAboveMessageBody1VerticalSpacerHeight;
        }
    }
    
    // Message Body 1
    if ([self.messageBody1Text apps_hasContent] || self.showActivityIndicator) {
        self.aboveMessageBody1VerticalSpacerConstraint.constant = self.defaultAboveMessageBody1VerticalSpacerHeight;
        self.activityIndicatorHeightConstraint.constant = self.defaultAboveActivityIndicatorVerticalSpacerHeight;
    }
    else {
        self.activityIndicatorHeightConstraint.constant = 0;
    }
    
    // Message Body 2
    if ([self.messageBody2Text apps_hasContent] || self.showActivityIndicator) {
        self.aboveMessageBody2VerticalSpacerConstraint.constant = self.defaultAboveMessageBody2VerticalSpacerHeight;
        self.aboveActionButtonVerticalSpacerConstraint.constant = self.defaultAboveActionButtonVerticalSpacerHeight;
    }
    else {
        // Without an activity indicator nor message body 2, we may as well collapse the space between them.
        self.aboveMessageBody2VerticalSpacerConstraint.constant = 0;
        self.aboveActionButtonVerticalSpacerConstraint.constant = 0;
    }
}


/**
 Applies or removes a constraint for the dialog view's height and width to match up (or not).
 This is driven by the boolean preference, @c useSquareDimensions.
 */
- (void)adjustSquareDimensionsConstraint;
{
    if (self.useSquareDimensions) {
        if (!self.squareDimensionsConstraint) {
           self.squareDimensionsConstraint = [NSLayoutConstraint constraintWithItem:self.dialogView
                                                                          attribute:NSLayoutAttributeWidth
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self.dialogView
                                                                          attribute:NSLayoutAttributeHeight
                                                                         multiplier:1
                                                                           constant:0];
            
            self.fixedWidthConstraint = [NSLayoutConstraint constraintWithItem:self.dialogView
                                                                           attribute:NSLayoutAttributeWidth
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:nil
                                                                           attribute:NSLayoutAttributeNotAnAttribute
                                                                          multiplier:1
                                                                            constant:240];
            
            [self.dialogView addConstraint:self.fixedWidthConstraint];
            [self.dialogView addConstraint:self.squareDimensionsConstraint];
        }
    }
    else if (self.squareDimensionsConstraint) {
        [self.dialogView removeConstraint:self.squareDimensionsConstraint];
        [self.dialogView removeConstraint:self.fixedWidthConstraint];
    }
}



#pragma mark - Inquiries

- (BOOL)hasAnActiveButton;
{
    return ([self.actionButtonTitleText apps_hasContent] ||
            [self.cancelButtonTitleText apps_hasContent]);
}


#pragma mark - User Actions

- (IBAction)handleActionButtonTapped:(id)sender
{
    logInfo(@"");
    [self processActionButtonCallback];
}


- (IBAction)handleCancelButtonTapped:(id)sender
{
    logInfo(@"");
    if (self.cancelButtonTappedCallback) {
        self.cancelButtonTappedCallback();
    }
}



#pragma mark - Invoking Callbacks

- (void)processActionButtonCallback;
{
    if (self.actionButtonTappedCallback) {
        self.actionButtonTappedCallback();
    }
}


#pragma mark - Requests

- (void)startAnimatingActivityIndicator;
{
    [self.activityIndicator startAnimating];
}

- (void)stopAnimatingActivityIndicator;
{
    [self.activityIndicator stopAnimating];
}



#pragma mark - Protocol: UIViewControllerTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented
                                                      presentingViewController:(UIViewController *)presenting
                                                          sourceViewController:(UIViewController *)source
{
    return [[APPSSimplePresentationController alloc] initWithPresentedViewController:presented
                                                            presentingViewController:presenting];
}



@end
