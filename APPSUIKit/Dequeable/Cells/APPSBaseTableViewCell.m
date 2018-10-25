//
//  APPSBaseTableViewCell.m
//
//  Created by Sohail Ahmed on 6/21/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

@import APPSFoundation;

#import "APPSBaseTableViewCell.h"
#import "UIView+Appstronomy.h"
#import "UIColor+Appstronomy.h"

@interface APPSBaseTableViewCell ()

#pragma mark weak

/**
 The view used to hide the default iOS given separator line, if our property @c isSeparatorHidden is set to YES.
 */
@property (nonatomic, weak) UIView *separatorCover;


#pragma mark strong

/**
 Readwrite version of property exposed in the header.
 */
@property (nonatomic, strong, readwrite) UIView *manualSeparatorView;

@end



@implementation APPSBaseTableViewCell {
    BOOL _manualSeparatorEngaged;
}

@synthesize textLabelUsesTintColor = _textLabelUsesTintColor;


#pragma mark - Lifecycle

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self applyDefaults];
    }
    return self;
}


- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self configureBackgroundViews];
    [self reconfigureManualSeparator];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self applyEditingModeBackgroundViewPositionCorrections];
    [self reconfigureSeparatorCover];
}



#pragma mark - Property Overrides

- (void)setDefaultSeparatorHidden:(BOOL)defaultSeparatorHidden
{
    if (_defaultSeparatorHidden != defaultSeparatorHidden) {
        _defaultSeparatorHidden = defaultSeparatorHidden;
        
        [self setNeedsLayout];
    }
}


- (void)setTextLabelUsesTintColor:(BOOL)textLabelUsesTintColor
{
    if (_textLabelUsesTintColor != textLabelUsesTintColor) {
        _textLabelUsesTintColor = textLabelUsesTintColor;
        
        if (textLabelUsesTintColor) {
            self.textLabel.textColor = self.tintColor;
        }
    }
}


- (UITableView *)owningTableView
{
    UIView *view = self.superview;
    while (view && ![view isKindOfClass:[UITableView class]]) {
        view = view.superview;
    }
    
    return (UITableView *)view;
}


- (BOOL)isManualSeparatorEnabled;
{
    return _manualSeparatorEngaged;
}


- (void)setManualSeparatorEnabled:(BOOL)manualSeparatorEnabled
{
    if (_manualSeparatorEngaged != manualSeparatorEnabled) {
        _manualSeparatorEngaged = manualSeparatorEnabled;

        [self reconfigureManualSeparator];
    }
}


- (UIView *)manualSeparatorView;
{
    // Do we not yet have a manual separator view installed as a subview?
    if ( !_manualSeparatorView || !_manualSeparatorView.superview) {
        _manualSeparatorView = [self createManualSeparatorView];
    };

    return _manualSeparatorView;
}


- (void)setManualSeparatorInsetLeft:(CGFloat)manualSeparatorInsetLeft
{
    if (_manualSeparatorInsetLeft != manualSeparatorInsetLeft) {
        _manualSeparatorInsetLeft = manualSeparatorInsetLeft;

        // Do we have a manual separator engaged already?
        if (_manualSeparatorEngaged) {
            // YES: Only then is it worth removing and reconfiguring:
            [self uninstallManualSeparatorView];
            [self reconfigureManualSeparator];
        }
    }
}



- (void)setManualSeparatorInsetRight:(CGFloat)manualSeparatorInsetRight
{
    if (_manualSeparatorInsetRight != manualSeparatorInsetRight) {
        _manualSeparatorInsetRight = manualSeparatorInsetRight;

        // Do we have a manual separator engaged already?
        if (_manualSeparatorEngaged) {
            // YES: Only then is it worth removing and reconfiguring:
            [self uninstallManualSeparatorView];
            [self reconfigureManualSeparator];
        }
    }
}


#pragma mark - UIView

- (void)tintColorDidChange
{
    if (self.textLabelUsesTintColor) {
        self.textLabel.textColor = self.tintColor;
    }
}



#pragma mark - Configuration

- (void)applyDefaults;
{
    self.manualSeparatorInsetLeft = kAPPSBaseTableViewCell_ManualSeparator_DefaultInsetLeft;
    self.manualSeparatorInsetRight = kAPPSBaseTableViewCell_ManualSeparator_DefaultInsetRight;
}


- (void)reconfigureSeparatorCover;
{
    // hide separator by putting our view over top of Apple's
    if (self.defaultSeparatorHidden) {
        
        if (!self.separatorCover) {
            UIView *separatorCover = [[UIView alloc] init];
            separatorCover.backgroundColor = self.contentView.backgroundColor ?: [UIColor whiteColor];
            [self addSubview:separatorCover];
            self.separatorCover = separatorCover;
        }
        
        CGRect cellBounds = self.bounds;
        CGRect frame = cellBounds;
        frame.size.height = [UIView apps_hairlineThickness];
        frame.origin.y = CGRectGetMaxY(cellBounds)-frame.size.height;
        self.separatorCover.frame = frame;
    }
    else {
        [self.separatorCover removeFromSuperview];
    }
}


- (void)reconfigureManualSeparator;
{
    if (_manualSeparatorEngaged) {
        [self engageManualSeparatorAnimated:NO];
    }
    else {
        [self disengageManualSeparatorAnimated:NO];
    }
}


- (void)uninstallManualSeparatorView
{
    [_manualSeparatorView removeFromSuperview];
    _manualSeparatorView = nil;
}



#pragma mark - Manual Separator

- (UIView *)createManualSeparatorView;
{
    UIView *manualSeparatorView;
    
    CGFloat hairlineThickness = [UIView apps_hairlineThickness];
    CGRect starterFrame = CGRectMake(0,0,self.bounds.size.width, hairlineThickness);
    manualSeparatorView = [[UIView alloc] initWithFrame:starterFrame];
    manualSeparatorView.backgroundColor = UIColorFromRGB(kAPPSBaseTableViewCell_ManualSeparator_DefaultColor);
    manualSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Add as subview, and install auto-layout constraints:
    [self.contentView addSubview:manualSeparatorView];
    NSDictionary *viewsDictionary = @{ @"separator" : manualSeparatorView };
    NSDictionary *metricsDictionary = @{ @"hairlineThickness"   : @(hairlineThickness),
                                         @"leftInset"           : @(self.manualSeparatorInsetLeft),
                                         @"rightInset"          : @(self.manualSeparatorInsetRight) };
    
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(leftInset)-[separator]-(rightInset)-|"
                                                                             options:(NSLayoutFormatOptions) 0
                                                                             metrics:metricsDictionary
                                                                               views:viewsDictionary];
    
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[separator(hairlineThickness)]|"
                                                                           options:(NSLayoutFormatOptions) 0
                                                                           metrics:metricsDictionary
                                                                             views:viewsDictionary];
    [self addConstraints:horizontalConstraints];
    [self addConstraints:verticalConstraints];
    
    return manualSeparatorView;
}


- (void)engageManualSeparatorAnimated:(BOOL)animated
{
    _manualSeparatorEngaged = YES; // Indicate that we are now engaged, since we soon will be.

    [UIView animateWithDuration:(animated ? 0.25 : 0.0)
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent)
                     animations:^{
                         [self manualSeparatorView].alpha = 1.0;
                     }
                     completion:nil];
    
}


- (void)disengageManualSeparatorAnimated:(BOOL)animated
{
    _manualSeparatorEngaged = NO; // Indicate that we are now disengaged, since we soon will be.

    [UIView animateWithDuration:(animated ? 0.25 : 0.0)
                          delay:0.0
                        options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent)
                     animations:^{
                         [self manualSeparatorView].alpha = 0.0;
                     }
                     completion:nil];
}



#pragma mark - Workarounds

/**
 When using a backgroundView or selectedBackgroundView on a custom UITableViewCell subclass, iOS7 currently
 has a bug where tapping the Delete access control reveals the Delete button, only to have the background cover it up
 again! Radar 14940393 has been filed for this. Until solved, use this method in your Table Cell's layoutSubviews
 to correct the behavior.
 
 This solution courtesy of cyphers72 on the Apple Developer Forum, who posted the
 working solution here: https://devforums.apple.com/message/873484#873484
 */
- (void)applyEditingModeBackgroundViewPositionCorrections {
    if (!self.editing) { return; } // BAIL. This fix is not needed.
    
    // Assertion: we are in editing mode.
    
    // Do we have a regular background view?
    if (self.backgroundView) {
        // YES: So adjust the frame for that:
        CGRect backgroundViewFrame = self.backgroundView.frame;
        backgroundViewFrame.origin.x = 0;
        self.backgroundView.frame = backgroundViewFrame;
    }
    
    // Do we have a selected background view?
    if (self.selectedBackgroundView) {
        // YES: So adjust the frame for that:
        CGRect selectedBackgroundViewFrame = self.selectedBackgroundView.frame;
        selectedBackgroundViewFrame.origin.x = 0;
        self.selectedBackgroundView.frame = selectedBackgroundViewFrame;
    }
}



#pragma mark - Abstract methods
#pragma mark Optional

- (void)configureBackgroundViews {}


@end
