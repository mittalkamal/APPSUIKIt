//
//  NSMutableAttributedString+Appstronomy.m
//
//  Created by Sohail Ahmed on 2015-04-11.
//

#import <UIKit/UIKit.h>
#import "APPSMarkupStyle.h"

#import "NSMutableAttributedString+Appstronomy.h"

@implementation NSMutableAttributedString (Appstronomy)

// CREDIT: http://stackoverflow.com/a/29362206/535054
- (void)apps_setTextAsLink:(NSString *)textToFind withLinkURL:(NSString *)url linkColor:(UIColor *)linkColor;
{
    NSRange range = [self.mutableString rangeOfString:textToFind options:NSCaseInsensitiveSearch];
    
    if (range.location != NSNotFound) {
        [self addAttribute:NSLinkAttributeName value:url range:range];
        [self addAttribute:NSForegroundColorAttributeName value:linkColor range:range];
    }
}


- (void)apps_applyMarkupStyles:(NSArray *)markupStyles
{
    [self beginEditing];

    for (APPSMarkupStyle *style in markupStyles) {
        [self apps_applyMarkupStyle:style];
    }
    
    [self endEditing];
}


- (void)apps_applyMarkupStyle:(APPSMarkupStyle *)markupStyle
{
    [self beginEditing];
    
    while (YES) {
        
        // Find range of open markup
        NSRange openMarkupRange = [self.mutableString rangeOfString:markupStyle.markup];
        if (openMarkupRange.location == NSNotFound) {
            break;
        }
        
        // Find range of close markup
        NSRange closeMarkupRange = [self.mutableString rangeOfString:markupStyle.closeMarkup];
        if (closeMarkupRange.location == NSNotFound) {
            NSLog(@"Error finding close markup %@. Make sure you open and close your markups correctly.", markupStyle.closeMarkup);
            break;
        }

        // Calculate the style range that represent the string between the open and close markups
        NSRange styleRange = NSMakeRange(openMarkupRange.location, closeMarkupRange.location + closeMarkupRange.length - openMarkupRange.location);

        // Apply style to markup
        [self addAttributes:markupStyle.attributes range:styleRange];

        // Remove closing markup in string
        [self.mutableString replaceCharactersInRange:NSMakeRange(closeMarkupRange.location, closeMarkupRange.length) withString:@""];
        
        // Remove opening markup in string
        [self.mutableString replaceCharactersInRange:NSMakeRange(openMarkupRange.location, openMarkupRange.length) withString:@""];
    }
    
    [self endEditing];
}

@end
