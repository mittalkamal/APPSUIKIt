//
//  WKWebView+Appstronomy.h
//  AppstronomyStandardKit
//
//  Created by Ken Grigsby on 6/28/16.
//  Copyright © 2016 Appstronomy, LLC. All rights reserved.
//

#import <WebKit/WebKit.h>

@interface WKWebView (Appstronomy)

/**
 This method loads an empty string into a web view so that WebKit performs any necessary first time setup. This
 should be called early in the application startup (i.e. applicationDidFinishLaunching) so that subsequent
 uses of a web view load more quickly.
 */
+ (void)primeWebKit;

@end
