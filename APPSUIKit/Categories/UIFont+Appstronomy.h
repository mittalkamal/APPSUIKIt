//
//  UIFont+Appstronomy.h
//  PKPDCalculator
//
//  Created by Ken Grigsby on 4/25/15.
//  Copyright (c) 2015 Appstronomy, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFont (Appstronomy)

/**
 Returns an bold version of the receiver or
 self if it's already bold
 */
- (UIFont *)apps_boldFont;


/**
 Returns an italicized version of the receiver or
 self if it's already italicized
 */
- (UIFont *)apps_italicizedFont;


/**
 Returns an non-stylized version of the receiver or
 self if it's already non-stylized
 */
- (UIFont *)apps_nonStylizedFont;


@end
