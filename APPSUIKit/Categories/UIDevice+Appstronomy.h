//
//  UIDevice+Appstronomy.h
//  Appstronomy Standard Kit
//
//  Created by Sohail Ahmed on 2014-12-19.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (Appstronomy)

+ (CGFloat)apps_nativeScreenWidthInPoints;

+ (CGFloat)apps_nativeScreenHeightInPoints;

+ (CGSize)apps_nativeScreenSizeInPoints;

/**
 Advises on whether we are currently running in the simulator.
 
 @return YES if we are running in a simulator; regardless of device type.
 */
+ (BOOL)apps_isSimulator;


/**
 Advises if this is a real, physical device. Effectively, it returns 
 the negation of the value returned by @c +apps_isSimulator.
 
 @return YES if we are running on a real device.
 */
+ (BOOL)apps_isRealDevice;


@end
