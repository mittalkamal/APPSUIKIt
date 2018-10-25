//
//  APPSBaseTableViewCell.h
//
//  Created by Sohail Ahmed on 6/21/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark - Constants

// Dimensions
static const CGFloat kAPPSBaseTableViewCell_ManualSeparator_DefaultInsetLeft    = 15.0;
static const CGFloat kAPPSBaseTableViewCell_ManualSeparator_DefaultInsetRight   = 0.0;

// Colours
static const NSInteger kAPPSBaseTableViewCell_ManualSeparator_DefaultColor      = 0xC8C7CC; 


@interface APPSBaseTableViewCell : UITableViewCell

#pragma mark scalar

/**
 Indicates whether this table cell should be selectable. Made available for subclasses,
 as there's no default implementation associated with this property at this base class level.
 */
@property (nonatomic, assign, getter=isSelectable) BOOL selectable;

/**
 Defaults to NO. Indicates whether we should effectively hide our table cell separator by
 placing a view over-top it that blends in with our background color, providing the appearance
 of no cell separator line.
 
 If you need to go down this route, consider instead having the table view configured with 
 no separator lines at all, and using our manually drawn separator lines facility, here at the
 table cell level.
 */
@property (nonatomic, assign, getter=isDefaultSeparatorHidden) BOOL defaultSeparatorHidden;


/**
 Set to YES to have the textLabel.textColor use and track changes to self.tintColor.
 This is helpful when you are using a default table style that makes use of the built-in 
 @c textLabel property.
 */
@property (nonatomic, assign) BOOL textLabelUsesTintColor;


/**
 Engages (or disengages) the manually drawn separator line. Defaults to NO.
 Use this when you have the containing UITableView separator lines turned off so that you can control
 your own with fine-tune precision.
 */
@property (nonatomic, assign, getter=isManualSeparatorEnabled) BOOL manualSeparatorEnabled;

/**
 When the manual separator is used, this property defines what left inset to use. 
 Initially set to a default that you can overwrite.
 */
@property (assign, nonatomic) CGFloat manualSeparatorInsetLeft;


/**
 When the manual separator is used, this property defines what right inset to use. 
 Initially set to a default that you can overwrite.
 */
@property (assign, nonatomic) CGFloat manualSeparatorInsetRight;


#pragma mark weak

/**
 The table view containing this table cell.
 */
@property (nonatomic, weak, readonly) UITableView *owningTableView;


#pragma mark strong

/**
 The view we use for a manual separator line, if it was requested with the property @c manualSeparatorEnabled.
 */
@property (nonatomic, strong, readonly) UIView *manualSeparatorView;


#pragma mark - Abstract Methods
#pragma mark Optional

/**
 This method is called in our @c awakeFromNib, although we provide no default implementation.
 It is a hook for subclasses to configure background views, should they need to.
 */
- (void)configureBackgroundViews;



#pragma mark - Configuration

/**
 Subclass implementations should call super in when they perform their own default configuration.
 This method is called when the table cell instance is initialized. Do not perform any nib-wiring-dependent
 default initialization here. Instead, do such operations in @c prepareForReuse or @c awakeFromNib, as appropriate.
 */
- (void)applyDefaults;


#pragma mark - Manual Separator

/**
 Used to engage the manual separator. Does nothing if the separator is already engaged.
 If you don't need a fade in animation, you can use the simpler boolean property, @c manualSeparatorEnabled.
 */
- (void)engageManualSeparatorAnimated:(BOOL)animated;


/**
 Used to disengage the manual separator. Does nothing if the separator is already disengaged.
 If you don't need a fade out animation, you can use the simpler boolean property, @c manualSeparatorEnabled.
 */
- (void)disengageManualSeparatorAnimated:(BOOL)animated;


@end
