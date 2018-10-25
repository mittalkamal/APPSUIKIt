//
//  APPSActivityStatusViewController.h
//
//  Created by Sohail Ahmed on 8/15/15.
//

@import APPSFoundation;

#import "APPSBaseViewController.h"

/**
 Presents a full screen view controller with mostly transparent border and
 an alert style message panel in the center. We are configured to use the
 @c APPSSimplePresentationController so that when we are presented,
 the previous view controller is visible through the dimming screen 
 underneath us.
 
 Callers must call @c -updateView after changing any of our model information in
 order to have this reflected in our dialog view configuration.
 */
@interface APPSActivityStatusViewController : APPSBaseViewController

#pragma mark scalar

@property (assign, nonatomic) BOOL showActivityIndicator;

@property (assign, nonatomic) BOOL animateActivityIndicator;

/**
 Indicates whether we should force the height and width to match,
 so that our visible dialog panel has a square shape. We'll still
 retain rounded corners, however.
 */
@property (assign, nonatomic) BOOL useSquareDimensions;


#pragma mark copy
// Model
@property (copy, nonatomic) NSString *messageTitleText;
@property (copy, nonatomic) NSString *messageBody1Text;
@property (copy, nonatomic) NSString *messageBody2Text;
@property (copy, nonatomic) NSString *actionButtonTitleText;
@property (copy, nonatomic) NSString *cancelButtonTitleText;

// Callbacks
@property (copy, nonatomic) APPSCallbackBlock actionButtonTappedCallback;
@property (copy, nonatomic) APPSCallbackBlock cancelButtonTappedCallback;


#pragma mark - Instantiation

+ (instancetype)activityController;



#pragma mark - Configuration

/**
 Clears all model values, setting them to nil.
 */
- (void)applyDefaults;


/**
 Call this whenever you change one or more of our model settings.
 */
- (void)updateView;


#pragma mark - Requests

- (void)startAnimatingActivityIndicator;

- (void)stopAnimatingActivityIndicator;


#pragma mark - User Actions

- (IBAction)handleActionButtonTapped:(id)sender;

- (IBAction)handleCancelButtonTapped:(id)sender;


#pragma mark - Invoking Callbacks

- (void)processActionButtonCallback;


@end
