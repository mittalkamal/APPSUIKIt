//
//  UIColor+UIColor_Appstronomy.h
//  PKPDCalculator
//
//  Created by Tim Capes on 2015-02-24.
//  Copyright (c) 2015 Appstronomy, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Colors

// Note: We are using #define constants for use here, because the the macro SingletonColorFromHex
// which we wish to use, does not play well with static * const.

#define kAPPSColorHex_DARK_GRAY_1       0x8E8E93
#define kAPPSColorHex_LIGHT_GRAY_3      0xC8C7CC
#define kAPPSColorHex_LIGHT_GRAY_2      0xD9D9D9
#define kAPPSColorHex_DIALOG_WHITE      0xFFFFFF


@interface UIColor (Appstronomy)

/**
 Create color from a hex value (e.g. 0xC4C4C4)
 and alpha of 1.0.
 */
+ (UIColor *)apps_colorWithHex:(unsigned long)hex
NS_SWIFT_NAME(init(hex:));


/**
 Create color from a hex value (e.g. 0xC4C4C4)
 and alpha.
 */
+ (UIColor *)apps_colorWithHex:(unsigned long)hex alpha:(CGFloat)alpha
NS_SWIFT_NAME(init(hex:alpha:));


/**
 Field captions.
 */
+ (UIColor *)apps_darkGray1Color;


/**
 Apple's default color for cell highlights.
 */
+ (UIColor *)apps_lightGray2Color;


/**
 Apple's default color for cell separators.
 */
+ (UIColor *)apps_lightGray3Color;


@end

NS_ASSUME_NONNULL_END
