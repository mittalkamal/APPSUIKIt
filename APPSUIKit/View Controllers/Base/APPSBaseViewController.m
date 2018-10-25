//
//  APPSBaseViewController.m
//
//  Created by Sohail Ahmed on 5/12/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import "APPSBaseViewController.h"

@implementation APPSBaseViewController

#pragma mark - Configuration: UIViewController

/**
 Override from UIViewController. We need white status bar text.
 TODO: Figure out how to set this in the project's info plist globally, so we don't resort to setting it in code.
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
