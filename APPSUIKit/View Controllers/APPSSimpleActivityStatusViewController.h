//
//  APPSSimpleActivityStatusViewController.h
//
//  Created by Sohail Ahmed on 11/12/15.
//

#import "APPSBaseViewController.h"

#pragma mark - Constants

/**
 This is the default blur effect style we'll use if a blur is called for an a
 different effect style is not requested.
 */
static const UIBlurEffectStyle kAPPSSimpleActivityStatus_DefaultBlurEffectStyle       = UIBlurEffectStyleExtraLight;

/**
 The rounding we'll apply to the dialog panel.
 */
static const CGFloat kAPPSSimpleActivityStatus_DefaultRoundedCornerRadius             = 20;

/**
 Regardless of what's in the Xib, we apply this default @b width, unless 
 overridden by callers.
 */
static const CGFloat kAPPSSimpleActivityStatus_DefaultDialogWidth                     = 220;

/**
 Regardless of what's in the Xib, we apply this default @b height, unless 
 overridden by callers.
 */
static const CGFloat kAPPSSimpleActivityStatus_DefaultDialogHeight                    = 200;

/**
 Regardless of what's in the Xib, we apply this default @b horizontal centering 
 offset (constant), unless overridden by callers.
 */
static const CGFloat kAPPSSimpleActivityStatus_DefaultDialogHorizontalCenteringOffset = 0;

/**
 Regardless of what's in the Xib, we apply this default @b vertical centering 
 offset (constant), unless overridden by callers.
 */
static const CGFloat kAPPSSimpleActivityStatus_DefaultDialogVerticalCenteringOffset   = 0;



/**
 Displays a rectangular dialog panel with a single large activity indicator and 
 message text. Optionally, you can have this displayed in front of a blur.
 
 We use the @c APPSSimplePresentationController by default, to allow us to display
 over-top of the currently visible view controller. The majority of this view controller
 is of a clear color, so that the view controller presenting us, is still visible.
 
 When we're configured to use a blur, we instruct our presentation controller to @em not
 use a dimming view. However, when we are not using a blur, we'll explicitly advise our
 presentation controller to use a dimming view over the view controller presenting us.
 This is so our role as a modal dialog brings with it, focus.
 
 You can configure many properties of this view controller, including:
    * Size of the dialog panel
    * Centering offsets of the dialog panel
    * Color of the activity indicator graphic
    * Message text
    * Message label font (by way of direct access to the @c messageLabel property)
    * The blur effect style
    * Whether to even use a blur effect or not; this only affects the dialog panel, 
      not the entire view controller backdrop.
    * The background color of the dialog view, should no blur effect be selected for use.
 
 */
@interface APPSSimpleActivityStatusViewController : APPSBaseViewController

#pragma mark scalar

/**
 Defaults to NO. Be sure to set a @c blurEffectStyle before engaging this,
 otherwise you'll only be able to use the default style.
 
 Remember, this only blurs the rectangular area behind the dialog panel (view) itself.
 Turning this on will NOT blur the entire view controller shown behind us. For that 
 effect, you'll want to use the @c APPSBlurPresentingViewPresentationController in
 conjunction with this controller.
 
 Future Enhancement: This view controller could give you that option.
 */
@property (assign, nonatomic) BOOL useBlurEffectBackground;

/**
 Defaults to @c UIBlurEffectStyleExtraLight. You must set this @em before
 you set @c useBlurEffectBackground to YES. We use this to know what style
 to initialize the blur with.
 */
@property (assign, nonatomic) UIBlurEffectStyle blurEffectStyle;

/**
 Optional. Defaults to @c kAPPSSimpleActivityStatus_DefaultDialogWidth.
 You may set a different width that you'd like to use.
 */
@property (assign, nonatomic) CGFloat dialogWidth;

/**
 Optional. Defaults to @c kAPPSSimpleActivityStatus_DefaultDialogHeight.
 You may set a different height that you'd like to use.
 */
@property (assign, nonatomic) CGFloat dialogHeight;

/**
 Optional. Defaults to @c kAPPSSimpleActivityStatus_DefaultDialogHorizontalCenteringOffset.
 You may set a different offset that you'd like to use, so that the dialog view
 is not exactly centered horizontally, but rather, centered with an offset applied.
 */
@property (assign, nonatomic) CGFloat dialogHorizontalCenteringOffset;

/**
 Optional. Defaults to @c kAPPSSimpleActivityStatus_DefaultDialogVerticalCenteringOffset.
 You may set a different offset that you'd like to use, so that the dialog view
 is not exactly centered vertically,, but rather, centered with an offset applied.
 */
@property (assign, nonatomic) CGFloat dialogVerticalCenteringOffset;


#pragma mark copy

/**
 The text you'd like displayed in the dialog panel.
 */
@property (copy, nonatomic) NSString *messageText;

/**
 This setting is ignored if @c useBlurEffectBackground is YES. In such a case,
 the @c dialogView's background color is set to clear, to see the blur
 effect come in behind it. Defaults to a light gray.
 */
@property (copy, nonatomic) UIColor *dialogViewBackgroundColor;


#pragma mark strong

/**
 Let's you specify what color to set the activity indicator to. We'll
 apply this to the @c color property of the @c UIActivityIndicatorView displayed.
 */
@property (strong, nonatomic) UIColor *activityIndicatorColor;


#pragma mark outlets

/**
 Direct access to the already instantiated, large @c UIActivityIndicatorView that
 we display. If you just want to change the color, you can instead set the 
 @c activityIndicatorColor property with the color of your choice.
 */
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

/**
 Direct access to the already instantiated message @c UILabel instance that we display.
 This allows you to change the default font, or even to set your own attributed string.
 */
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;



#pragma mark - Instantiation

/**
 Instantiates a @c APPSSimpleActivityStatusViewController, configured with defaults.
 You'll still want to set the @c messageText and start the activty indicator spinning
 yourself.
 
 @return A view controller configured with defaults.
 */
+ (instancetype)activityController;



#pragma mark - Requests

/**
 Starts the activity indicator spinning.
 */
- (void)startAnimatingActivityIndicator;



/**
 Stops the activity indicator from spinning.
 */
- (void)stopAnimatingActivityIndicator;


@end
