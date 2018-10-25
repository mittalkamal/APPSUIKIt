//
//  APPSMarkupStyleTest.m
//
//  Created by Ken Grigsby on 10/17/15.
//

@import XCTest;

#import "APPSMarkupStyle.h"
#import "UIFont+Appstronomy.h"

@interface APPSMarkupStyleTest : XCTestCase

@end

@implementation APPSMarkupStyleTest


/**
 Verify init method throws if markup doesn't being with '<'
 */
- (void)testInit_MissingLessThan
{
    APPSMarkupStyle *style = [APPSMarkupStyle alloc];
    XCTAssertThrows([style initWithMarkup:@"xxx"]);
}


/**
 Verify init method throws if markup doesn't end with '>'
 */
- (void)testInit_MissingGreaterThan
{
    APPSMarkupStyle *style = [APPSMarkupStyle alloc];
    XCTAssertThrows([style initWithMarkup:@"<xxx"]);
}


/**
 Verify init method doesn't throw if markup beings with '<'
 */
- (void)testInit_HasLessThanAndGreaterThan
{
    APPSMarkupStyle *style = [APPSMarkupStyle alloc];
    XCTAssertNoThrow([style initWithMarkup:@"<i>"]);
}


/**
 Verify closeMarkup method
 */
- (void)testCloseMarkup
{
    APPSMarkupStyle *style = [[APPSMarkupStyle alloc] initWithMarkup:@"<i>"];
    NSString *expectedCloseMarkup = @"</i>";
    XCTAssertEqualObjects(style.closeMarkup, expectedCloseMarkup);
}


/**
 Verify setForegroundColor method sets attribute key NSForegroundColorAttributeName
 */
- (void)testSetForegroundColor
{
    UIColor *testColor = [UIColor blackColor];
    APPSMarkupStyle *style = [[APPSMarkupStyle alloc] initWithMarkup:@"<i>"];
    style.foregroundColor = testColor;
    
    NSDictionary *attributes = style.attributes;
    XCTAssertEqual(attributes.allKeys.count, 1);
    XCTAssertEqualObjects(attributes[NSForegroundColorAttributeName], testColor);
}


/**
 Verify setBackgroundColor method sets attribute key NSBackgroundColorAttributeName
 */
- (void)testSetBackgroundColor
{
    UIColor *testColor = [UIColor blackColor];
    APPSMarkupStyle *style = [[APPSMarkupStyle alloc] initWithMarkup:@"<i>"];
    style.backgroundColor = testColor;
    
    NSDictionary *attributes = style.attributes;
    XCTAssertEqual(attributes.allKeys.count, 1);
    XCTAssertEqualObjects(attributes[NSBackgroundColorAttributeName], testColor);
}


/**
 Verify setFont method sets attribute key NSFontAttributeName
 */
- (void)testSetFont
{
    UIFont *testFont = [UIFont systemFontOfSize:12.0];
    APPSMarkupStyle *style = [[APPSMarkupStyle alloc] initWithMarkup:@"<i>"];
    style.font = testFont;
    
    NSDictionary *attributes = style.attributes;
    XCTAssertEqual(attributes.allKeys.count, 1);
    XCTAssertEqualObjects(attributes[NSFontAttributeName], testFont);
}


/**
 Verify setFont method sets attribute key NSFontAttributeName
 */
- (void)testSetAttributes
{
    NSDictionary *testAttributes = @{ NSFontAttributeName: [UIFont systemFontOfSize:12.0],
                                      NSForegroundColorAttributeName: [UIColor yellowColor],
                                      NSBackgroundColorAttributeName: [UIColor greenColor],
                                      };
    APPSMarkupStyle *style = [[APPSMarkupStyle alloc] initWithMarkup:@"<i>"];
    style.attributes = testAttributes;
    
    XCTAssertEqualObjects(style.attributes, testAttributes);
}


/**
 Verify italicsMarkupStyleWithFont method sets attribute key NSFontAttributeName and APPSMarkupStyleTag_Italics
 */
- (void)testConvenienceInitializer_italics
{
    UIFont *testFont = [UIFont systemFontOfSize:12.0];
    APPSMarkupStyle *style = [APPSMarkupStyle italicsMarkupStyleWithFont:testFont];
    
    NSDictionary *attributes = style.attributes;
    UIFont *expectedFont = [testFont apps_italicizedFont];
    XCTAssertEqual(attributes.allKeys.count, 1);
    XCTAssertEqualObjects(style.markup, APPSMarkupStyleTag_Italics);
    XCTAssertEqualObjects(attributes[NSFontAttributeName], expectedFont);
}


@end
