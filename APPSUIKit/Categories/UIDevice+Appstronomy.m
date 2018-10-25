//
//  UIDevice+Appstronomy.m
//  Appstronomy Standard Kit
//
//  Created by Sohail Ahmed on 2014-12-19.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

@import APPSFoundation;

#import "UIDevice+Appstronomy.h"

#include <TargetConditionals.h> // Used to ensure macro TARGET_OS_SIMULATOR is loaded. Per: http://stackoverflow.com/a/32440869/535054

@implementation UIDevice (Appstronomy)

+ (CGFloat)apps_nativeScreenWidthInPoints;
{
    return [self apps_nativeScreenSizeInPoints].width;
}


+ (CGFloat)apps_nativeScreenHeightInPoints;
{
    return [self apps_nativeScreenSizeInPoints].height;
}


+ (CGSize)apps_nativeScreenSizeInPoints;
{
    // NOTE: Using 'bounds' instead of 'nativeBounds' isn't safe for rotated devices.
    // However, using the 'nativeBounds' property returns *pixels*, not points.
    // So we then use Retina-aware scaling methods to determine the appropriate scaling divider
    // to use to get to points.
    
    // For good background resources, see:
    // 1. http://www.paintcodeapp.com/news/iphone-6-screens-demystified
    // 2. http://stackoverflow.com/a/25756117/535054
    
    UIScreen *mainScreen = [UIScreen mainScreen];
    
    CGFloat screenWidth = mainScreen.nativeBounds.size.width / mainScreen.nativeScale;
    CGFloat screenHeight = mainScreen.nativeBounds.size.height / mainScreen.nativeScale;
    
    logDebug(@"Screen bounds: %@, Screen resolution: %@, scale: %f, nativeScale: %f. "
          "Returning screen size in points of {%0.0f, %0.0f}",
          NSStringFromCGRect(mainScreen.bounds),
          mainScreen.coordinateSpace,
          mainScreen.scale,
          mainScreen.nativeScale,
          screenWidth,
          screenHeight);

    return CGSizeMake(screenWidth, screenHeight);
}


+ (BOOL)apps_isSimulator;
{
#if TARGET_OS_SIMULATOR
    return YES;
#else
    return NO;
#endif
}


+ (BOOL)apps_isRealDevice;
{
    return ![self apps_isSimulator];
}



@end
