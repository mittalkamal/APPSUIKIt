//
//  UIColor+Appstronomy.m
//  PKPDCalculator
//
//  Created by Tim Capes on 2015-02-24.
//  Copyright (c) 2015 Appstronomy, LLC. All rights reserved.
//

@import APPSFoundation;

#import "UIColor+Appstronomy.h"


#define SingletonColorFromHex(hex)   \
static UIColor         *color;     \
static dispatch_once_t  onceToken; \
\
dispatch_once(&onceToken, ^{       \
color = UIColorFromRGB(hex);     \
});                                \
\
return color;


@implementation UIColor (Appstronomy)

+ (UIColor *)apps_colorWithHex:(unsigned long)hex
{
    return UIColorFromRGB(hex);
}


+ (UIColor *)apps_colorWithHex:(unsigned long)hex alpha:(CGFloat)alpha
{
    return UIColorFromRGBWithAlpha(hex, alpha);
}

+ (UIColor *)apps_darkGray1Color
{
    SingletonColorFromHex(kAPPSColorHex_DARK_GRAY_1);
}


+ (UIColor *)apps_lightGray3Color
{
    SingletonColorFromHex(kAPPSColorHex_LIGHT_GRAY_3);
}


+ (UIColor *)apps_lightGray2Color;
{
    SingletonColorFromHex(kAPPSColorHex_LIGHT_GRAY_2);
}


@end
