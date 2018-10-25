//
//  UINavigationBar+Appstronomy.m
//
//  Created by Ken Grigsby on 10/2/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

/*
 The code to remove the hair line is from http://stackoverflow.com/questions/19226965/how-to-hide-ios7-uinavigationbar-1px-bottom-line
 */

#import "UINavigationBar+Appstronomy.h"

@implementation UINavigationBar (Appstronomy)

- (void)apps_hideHairline
{
    UIImageView *imageView = [self apps_findHairlineImageViewUnderView:self];
    imageView.hidden = YES;
}


- (void)apps_showHairline
{
    UIImageView *imageView = [self apps_findHairlineImageViewUnderView:self];
    imageView.hidden = NO;
}


- (UIImageView *)apps_findHairlineImageViewUnderView:(UIView *)view
{
    if ([view isKindOfClass:UIImageView.class] && CGRectGetHeight(view.bounds) <= 1.0) {
        return (UIImageView *)view;
    }
    for (UIView *subview in view.subviews) {
        UIImageView *imageView = [self apps_findHairlineImageViewUnderView:subview];
        if (imageView) {
            return imageView;
        }
    }
    return nil;
}

@end
