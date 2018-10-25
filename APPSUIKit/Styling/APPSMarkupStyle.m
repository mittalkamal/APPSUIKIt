//
//  APPSMarkupStyle.m
//  Appstronomy UIKit
//
//  Created by Ken Grigsby on 10/17/15.
//  Copyright (c) 2015 Appstronomy, LLC. All rights reserved.
//

#import "APPSMarkupStyle.h"
#import "UIFont+Appstronomy.h"

@interface APPSMarkupStyle()

/**
 *  Attributes for styling class
 */
@property (strong, nonatomic) NSMutableDictionary *mutableAttributes;


@end

@implementation APPSMarkupStyle

- (instancetype)initWithMarkup:(NSString *)markup
{
    NSParameterAssert([markup hasPrefix:@"<"]);
    NSParameterAssert([markup hasSuffix:@">"]);
    
    self = [super init];
    if (self) {
        _markup = [markup copy];
    }
    
    return self;
}



#pragma mark - Setters

- (void)setForegroundColor:(UIColor *)color
{
    _foregroundColor = color;
    
    self.mutableAttributes[NSForegroundColorAttributeName] = color;
}


- (void)setBackgroundColor:(UIColor *)color
{
    _backgroundColor = color;
    
    self.mutableAttributes[NSBackgroundColorAttributeName] = color;
}


- (void)setFont:(UIFont *)font
{
    _font = font;
    
    self.mutableAttributes[NSFontAttributeName] = font;
}


- (void)setAttributes:(NSDictionary *)attributes
{
    self.mutableAttributes = [attributes mutableCopy];
}



#pragma mark - Getters

/**
 *  Getter for closeMarkup. Return a value based on markup
 *
 *  @return The close markup NSString
 */
- (NSString *)closeMarkup
{
    return [self.markup stringByReplacingOccurrencesOfString:@"<" withString:@"</"];
}


- (NSMutableDictionary *)mutableAttributes
{
    if (!_mutableAttributes) {
        _mutableAttributes = [[NSMutableDictionary alloc] init];
    }
    
    return _mutableAttributes;
}


- (NSDictionary *)attributes
{
    return [self.mutableAttributes copy];
}


@end


@implementation APPSMarkupStyle (ConvenienceInitializers)

+ (instancetype)italicsMarkupStyleWithFont:(UIFont *)font
{
    APPSMarkupStyle *style = [[APPSMarkupStyle alloc] initWithMarkup:APPSMarkupStyleTag_Italics];
    style.font = [font apps_italicizedFont];
    return style;
}

+ (instancetype)boldMarkupStyleWithFont:(UIFont *)font;
{
    APPSMarkupStyle *style = [[APPSMarkupStyle alloc] initWithMarkup:APPSMarkupStyleTag_Bold];
    style.font = [font apps_boldFont];
    return style;
}
@end

