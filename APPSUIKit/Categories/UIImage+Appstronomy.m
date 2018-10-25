//
//  UIImage+UIImage_Appstronomy.m
//  Appstronomy UIKit
//
//  Created by Tim Capes on 2014-11-21.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import "UIImage+Appstronomy.h"

@implementation UIImage (Appstronomy)

+ (UIImage *)imageWithColor:(UIColor *)color {
    return [UIImage imageWithColor:color andRect:CGRectMake(0, 0, 1, 1)];
}

+ (UIImage *)imageWithColor:(UIColor *)color andRect:(CGRect) rect {
    
    // Create a 1 by 1 pixel context
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with your color
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
