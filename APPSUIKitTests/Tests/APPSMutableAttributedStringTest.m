//
//  APPSMutableAttributedStringTest.m
//  PKPDCalculator
//
//  Created by Ken Grigsby on 10/17/15.
//  Copyright © 2015 Appstronomy, LLC. All rights reserved.
//

@import XCTest;

#import "NSMutableAttributedString+Appstronomy.h"
#import "APPSMarkupStyle.h"
#import "UIFont+Appstronomy.h"

@interface APPSMutableAttributedStringTest : XCTestCase

@end

@implementation APPSMutableAttributedStringTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testApplyItalicsStyle
{
    UIFont *testFont = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    XCTAssertNotNil(testFont);
    UIFont *italicizedFont = [testFont apps_italicizedFont];
    XCTAssertNotNil(italicizedFont);
    NSString *italizedStringPart = @"Pseudomonas aeruginosa";
    NSString *markedupString = [NSString stringWithFormat:@"<i>%@</i>, MDR", italizedStringPart];
    APPSMarkupStyle *italicsMarkup = [APPSMarkupStyle italicsMarkupStyleWithFont:testFont];
    
    // Create attributed string and apply markup style
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:markedupString];
    [attributedString apps_applyMarkupStyle:italicsMarkup];
    
    // Verify font was applied correctly
    // We're only expecting one attribute and it should be a font
    [attributedString enumerateAttributesInRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(NSDictionary<NSString *,id> *attrs, NSRange range, BOOL *stop) {
        if (attrs.count > 0) {
            
            // Expecting one attribute and it should NSFontAttributeName and the value should be an italized font
            XCTAssertEqual(attrs.count, 1);
            XCTAssertEqualObjects(attrs.allKeys.firstObject, NSFontAttributeName);
            XCTAssertEqualObjects(attrs.allValues.firstObject, italicizedFont);
            
            // For this test string the italics starts at location 0
            XCTAssertEqual(range.location, 0);
            XCTAssertEqual(NSMaxRange(range), italizedStringPart.length);
        }
    }];
}


- (void)testApplyBoldStyle
{
    UIFont *testFont = [UIFont fontWithName:@"HelveticaNeue" size:12.0];
    XCTAssertNotNil(testFont);
    UIFont *boldFont = [testFont apps_boldFont];
    XCTAssertNotNil(boldFont);
    NSString *boldStringPart = @"Pseudomonas aeruginosa";
    NSString *markedupString = [NSString stringWithFormat:@"<b>%@</b>, MDR", boldStringPart];
    APPSMarkupStyle *boldMarkup = [APPSMarkupStyle boldMarkupStyleWithFont:testFont];
    
    // Create attributed string and apply markup style
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:markedupString];
    [attributedString apps_applyMarkupStyle:boldMarkup];
    
    // Verify font was applied correctly
    // We're only expecting one attribute and it should be a font
    [attributedString enumerateAttributesInRange:NSMakeRange(0, attributedString.length) options:0 usingBlock:^(NSDictionary<NSString *,id> *attrs, NSRange range, BOOL *stop) {
        if (attrs.count > 0) {
            
            // Expecting one attribute and it should NSFontAttributeName and the value should be a bold font
            XCTAssertEqual(attrs.count, 1);
            XCTAssertEqualObjects(attrs.allKeys.firstObject, NSFontAttributeName);
            XCTAssertEqualObjects(attrs.allValues.firstObject, boldFont);
            
            // For this test string the italics starts at location 0
            XCTAssertEqual(range.location, 0);
            XCTAssertEqual(NSMaxRange(range), boldStringPart.length);
        }
    }];
}

@end
