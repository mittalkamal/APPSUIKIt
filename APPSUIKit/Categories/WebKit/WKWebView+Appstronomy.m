//
//  WKWebView+Appstronomy.m
//  AppstronomyStandardKit
//
//  Created by Ken Grigsby on 6/28/16.
//  Copyright © 2016 Appstronomy, LLC. All rights reserved.
//

#import "WKWebView+Appstronomy.h"

@implementation WKWebView (Appstronomy)

+ (void)primeWebKit
{
    WKWebView *dummyWebView = [WKWebView new];
    [dummyWebView loadHTMLString:@"" baseURL:nil];
}
@end
