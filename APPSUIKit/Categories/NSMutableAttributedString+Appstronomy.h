//
//  NSMutableAttributedString+Appstronomy.h
//
//  Created by Sohail Ahmed on 2015-04-11.
//

@import Foundation;
@import UIKit;

@class APPSMarkupStyle;

@interface NSMutableAttributedString (Appstronomy)

- (void)apps_setTextAsLink:(NSString *)textToFind withLinkURL:(NSString *)url linkColor:(UIColor *)linkColor;


/**
 Applies style to range of text designated by
 markup tag.
 
 @param style APPSMarkupStyle to be applied to range designated by markup tag.
 */
- (void)apps_applyMarkupStyle:(APPSMarkupStyle *)style;


/**
 Calls apps_applyMarkupStyle with each style in markupStyles
 
 @param markupStyles array of APPSMarkupStyle
 */
- (void)apps_applyMarkupStyles:(NSArray *)markupStyles;

@end
