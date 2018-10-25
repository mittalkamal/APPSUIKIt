//
//  APPSMarkupStyle.h
//  Appstronomy UIKit
//
//  Created by Ken Grigsby on 10/17/15.
//  Copyright (c) 2015 Appstronomy, LLC. All rights reserved.
//
//  Inspired from EMString - https://github.com/TanguyAladenise/EMString/tree/master/EMString
//

@import UIKit;

@interface APPSMarkupStyle : NSObject

- (instancetype)init __unavailable;

/**
 *  Init method for APPSMarkupStyle
 *
 *  @param markup The markup to identify styling. Must be in the form of : "<yourMarkup>".
 *
 *  @return An APPSMarkupStyle instance
 */
- (instancetype)initWithMarkup:(NSString *)markup NS_DESIGNATED_INITIALIZER;

/**
 *  A given name for a styling class. Optional field.
 */
@property (nonatomic, copy) NSString *name;


/**
 *  The markup identifying the styling to apply in the string
 */
@property (nonatomic, copy, readonly) NSString *markup;


/**
 *  The close markup for styling. Read-only property since close markup will be deduced from markup
 */
@property (nonatomic, copy, readonly) NSString *closeMarkup;


/**
 *  A dictionary containing the attributes to set for the NSAttributedString. For information about where to find the system-supplied attribute keys, see the overview section in NSAttributedString Class Reference.
 https://developer.apple.com/Library/ios/documentation/UIKit/Reference/NSAttributedString_UIKit_Additions/index.html#//apple_ref/doc/constant_group/Character_Attributes
 */
@property (nonatomic, copy) NSDictionary *attributes;


/**
 *  The foreground color to apply to the string. Convenient setter to populate attributes.
 */
@property (nonatomic, strong) UIColor *foregroundColor;


/**
 *  The background color to apply to the string. Convenient setter to populate attributes.
 */
@property (nonatomic, strong) UIColor *backgroundColor;


/**
 *  The font to apply to the string. Convenient setter to populate attributes.
 */
@property (nonatomic, strong) UIFont *font;


@end

/**
 Default markup tags
 */
static NSString * const APPSMarkupStyleTag_Italics  = @"<i>";
static NSString * const APPSMarkupStyleTag_Bold     = @"<b>";


@interface APPSMarkupStyle (ConvenienceInitializers)

/**
 Convenience method to create a markup style with mark of APPSMarkupStyleTag_Italics;
 The given font will be converted to an italics version using UIFontDescriptorTraitItalic.
 
 @param font font to use with italics tag
 
 @return markup style configured with italics font and italics markup tag
 */
+ (instancetype)italicsMarkupStyleWithFont:(UIFont *)font;


/**
 Convenience method to create a markup style with mark of APPSMarkupStyleTag_Bold;
 The given font will be converted to an italics version using UIFontDescriptorTraitBold.
 
 @param font font to use with bold tag
 
 @return markup style configured with bold font and bold markup tag
 */
+ (instancetype)boldMarkupStyleWithFont:(UIFont *)font;



@end
