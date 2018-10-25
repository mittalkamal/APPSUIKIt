//
//  UIApplication+Appstronomy.m
//
//  Created by Ken Grigsby on 11/5/15.
//  Copyright (c) 2015 Appstronomy, LLC. All rights reserved.
//

#import "UIApplication+Appstronomy.h"

@implementation UIApplication (Appstronomy)

- (void)apps_promptUserToConfigureMail
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:"] options:@{} completionHandler:nil];
}

@end
