//
//  UIFont+Appstronomy.m
//  PKPDCalculator
//
//  Created by Ken Grigsby on 4/25/15.
//  Copyright (c) 2015 Appstronomy, LLC. All rights reserved.
//

#import "UIFont+Appstronomy.h"

static const uint32_t UIFontDescriptorTraitMask = 0x0000FFFF;

@implementation UIFont (Appstronomy)

- (UIFont *)apps_boldFont
{
    UIFontDescriptor *fontDescriptor = self.fontDescriptor;
    UIFontDescriptorSymbolicTraits traits = fontDescriptor.symbolicTraits;
    
    // Check if the font is already Bold
    if ((traits & UIFontDescriptorTraitMask) == UIFontDescriptorTraitBold) {
        return self;
    }
    
    traits = (traits & ~UIFontDescriptorTraitMask) | UIFontDescriptorTraitBold;
    UIFontDescriptor *boldFontDescription = [fontDescriptor fontDescriptorWithSymbolicTraits:traits];
    UIFont *boldFont = [UIFont fontWithDescriptor:boldFontDescription size:self.pointSize];
    return boldFont;
}


- (UIFont *)apps_italicizedFont
{
    UIFontDescriptor *fontDescriptor = self.fontDescriptor;
    UIFontDescriptorSymbolicTraits traits = fontDescriptor.symbolicTraits;
    
    // Check if the font is already italicized
    if ((traits & UIFontDescriptorTraitMask) == UIFontDescriptorTraitItalic) {
        return self;
    }
    
    traits = (traits & ~UIFontDescriptorTraitMask) | UIFontDescriptorTraitItalic;
    UIFontDescriptor *italicizedFontDescription = [fontDescriptor fontDescriptorWithSymbolicTraits:traits];
    UIFont *italicizedFont = [UIFont fontWithDescriptor:italicizedFontDescription size:self.pointSize];
    return italicizedFont;
}


- (UIFont *)apps_nonStylizedFont
{
    UIFontDescriptor *fontDescriptor = self.fontDescriptor;
    UIFontDescriptorSymbolicTraits traits = fontDescriptor.symbolicTraits;
    
    // Check if the font is already non-stylized
    if ((traits & UIFontDescriptorTraitMask) == 0) {
        return self;
    }
    
    traits = (traits & ~UIFontDescriptorTraitMask);
    UIFontDescriptor *nonStylizedFontDescription = [fontDescriptor fontDescriptorWithSymbolicTraits:traits];
    UIFont *nonStylizedFont = [UIFont fontWithDescriptor:nonStylizedFontDescription size:self.pointSize];
    return nonStylizedFont;
}

@end
