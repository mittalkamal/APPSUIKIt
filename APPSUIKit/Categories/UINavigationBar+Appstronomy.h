//
//  UINavigationBar+Appstronomy.h
//
//  Created by Ken Grigsby on 10/2/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationBar (Appstronomy)

/**
 *  Hides the hairline imageView at the bottom of the navBar.
 *  This is useful to removing the line between the navBar and a toolbar.
 */
- (void)apps_hideHairline;


/**
 *  Shows the hairline imageView at the bottom of the nav bar.
 */
- (void)apps_showHairline;

@end
